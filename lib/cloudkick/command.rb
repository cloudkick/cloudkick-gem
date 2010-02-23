require 'commands/base'

Dir["#{File.dirname(__FILE__)}/commands/*"].each { |c| require c }

module Cloudkick
  module Command
    class InvalidCommand < RuntimeError; end
    class CommandFailed  < RuntimeError; end

    class << self
      def run(command, args)
        begin
          run_internal(command, args.dup)
        rescue InvalidCommand
          error "Unknown command. Run 'cloudkick help' for usage information."
        rescue CommandFailed => e
          error e.message
        rescue Interrupt => e
          error "\n[canceled]"
        end
      end

      def run_internal(command, args)
        klass, method = parse(command)
        runner = klass.new(args)
        raise InvalidCommand unless runner.respond_to?(method)
        runner.send(method)
      end

      def error(msg)
        STDERR.puts(msg)
        exit 1
      end

      def parse(command)
        return eval("Cloudkick::Command::#{command.capitalize}"), :index
      end
    end
  end
end
