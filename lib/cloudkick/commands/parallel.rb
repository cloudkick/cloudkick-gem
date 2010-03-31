require 'tempfile'

module Cloudkick::Command
  class Pssh < Base
    def index
      unless args.size == 6 or args.size == 8
        raise CommandFailed, 'usage: cloudkick pssh --query <query> ' \
        '--username <username> ' \
        '--command <command>'
      end

      query = extract_option('--query')
      username = extract_option('--username')
      command = extract_option('--command')
      
      file = Tempfile.new('ck')

      if query
        client.get('nodes', query).each do |node|
          file.puts node.ipaddress
        end
      else
        client.get('nodes').each do |node|
          file.puts node.ipaddress
        end
      end
      
      file.flush
      begin
        exec("pssh -i -h #{file.path} -l #{username} #{command}")
      rescue
        raise CommandFailed, 'cloudkick: command not found: pssh'
      end
      file.close
    end
  end

  class Pscp < Base
    def index
    end
  end
end
