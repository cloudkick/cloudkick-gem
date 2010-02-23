module Cloudkick::Command
  class Base
    attr_accessor :args

    def initialize(args)
      @args = args
    end

    def client
      if !@client
        key, secret = credentials
        @client = Cloudkick::Base.new(key, secret)
      end

      return @client
    end

    def credentials
      key = ''
      File.open('/etc/cloudkick.conf') do |f|
        f.grep(/oauth_key (\w+)/) { key = $1 }
      end

      secret = ''
      File.open('/etc/cloudkick.conf') do |f|
        f.grep(/oauth_secret (\w+)/) { secret = $1 }
      end

      return key, secret
    end

  end
end
