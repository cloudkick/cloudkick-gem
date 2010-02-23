require 'tempfile'

module Cloudkick::Command
  class Pssh < Base
    def index
      unless args.size == 3
        raise CommandFailed, 'usage: cloudkick pssh <username> <output> <command>'
      end

      file = Tempfile.new('ck')

      client.get('nodes').each do |node|
        file.puts node.ipaddress
      end
      
      file.flush
      exec("pssh -h #{file.path} -l #{@args[0]} -o #{args[1]} #{args[2]}")
      file.close
    end
  end

  class Pscp < Base
    def index
    end
  end
end
