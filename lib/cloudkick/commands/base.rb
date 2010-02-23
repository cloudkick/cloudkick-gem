module Cloudkick::Command
  class Base
    attr_accessor :args

    def initialize(args)
      @args = args
    end

    def display(msg, newline=true)
      if newline
        puts(msg)
      else
        print(msg)
        STDOUT.flush
      end
    end
    
    def client
      if !@client
        key, secret = credentials
        @client = Cloudkick::Base.new(key, secret)
      end

      return @client
    end

    def credentials
      begin
        key = ''
        File.open('/etc/cloudkick.conf') do |f|
          f.grep(/oauth_key (\w+)/) { key = $1 }
        end

        secret = ''
        File.open('/etc/cloudkick.conf') do |f|
          f.grep(/oauth_secret (\w+)/) { secret = $1 }
        end

        return key, secret
      rescue
        raise CommandFailed, 'Unable to open /etc/cloudkick.conf'
      end
    end

    def extract_option(options, default=true)
      values = options.is_a?(Array) ? options : [options]
      return unless opt_index = args.select { |a| values.include? a }.first
      opt_position = args.index(opt_index) + 1
      if args.size > opt_position && opt_value = args[opt_position]
        if opt_value.include?('--')
          opt_value = nil
        else
          args.delete_at(opt_position)
        end
      end
      opt_value ||= default
      args.delete(opt_index)
      block_given? ? yield(opt_value) : opt_value
    end
  end
end
