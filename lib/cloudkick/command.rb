require 'commands/base'

Dir["#{File.dirname(__FILE__)}/commands/*"].each { |c| require c }

module Cloudkick
  module Command
    class InvalidCommand < RuntimeError; end
    class CommandFailed  < RuntimeError; end

    class << self
      def run(command, args)
        run_internal(command, args.dup)
      end

      def run_internal(command, args)
        klass, method = parse(command)
        runner = klass.new(args)
        raise InvalidCommand unless runner.respond_to?(method)
        runner.send(method)
      end

      def parse(command)
        return eval("Cloudkick::Command::#{command.capitalize}"), :index
      end
    end
  end
end
