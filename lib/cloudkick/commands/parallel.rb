require 'tempfile'

module Cloudkick::Command
  class Pssh < Base
    def index
      unless args.size > 0
        raise CommandFailed, 'usage: cloudkick pssh --query <query> ' \
        '<command> ' \
        '[--username <username>]'
      end

      query = extract_option('--query')
      username = extract_option('--username')
      command = args.last.strip rescue nil
      
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
        if username
          system("pssh --inline --timeout=-1  --hosts=#{file.path} --user=#{username} '#{command}'")
        else
          system("pssh --inline --timeout=-1 --hosts=#{file.path} '#{command}'")
        end
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
