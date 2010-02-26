module Cloudkick::Command
  class Help < Base
    class HelpGroup < Array
      attr_reader :title

      def initialize(title)
        @title = title
      end

      def command(name, description)
        self << [name, description]
      end

      def space
        self << ['', '']
      end
    end

    def self.groups
      @groups ||= []
    end

    def self.group(title, &block)
      groups << begin
                  group = HelpGroup.new(title)
                  yield group
                  group
                end
    end

    def self.create_default_groups!
      group 'Commands' do |group|
        group.command 'help',                               'show this usage'
        group.command 'version',                            'show the gem version'
        group.space
        group.command 'pssh --query <query> ' \
        '--username <username> ' \
        '--output <output> ' \
        '--command <command>',
        'parallel ssh your nodes'
      end
    end

    def index
      display usage
    end

    def version
      display Cloudkick::Client.version
    end

    def usage
      longest_command_length = self.class.groups.map do |group|
        group.map { |g| g.first.length }
      end.flatten.max

      self.class.groups.inject(StringIO.new) do |output, group|
        output.puts "=== %s" % group.title
        output.puts

        group.each do |command, description|
          if command.empty?
            output.puts
          else
            output.puts "%-*s # %s" % [longest_command_length, command, description]
          end
        end

        output.puts
        output
      end.string
    end
  end
end

Cloudkick::Command::Help.create_default_groups!
