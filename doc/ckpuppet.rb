require 'rubygems'
require 'cloudkick'
require 'puppet'
require 'puppet/node'
require 'puppet/util/tagging'
require 'puppet/indirector/exec'

class Puppet::Node::Cloudkick < Puppet::Indirector::Code
  include Puppet::Util::Tagging

  # Create our client and cache
  def client
    key, secret = credentials
    @client ||= Cloudkick::Base.new(key, secret)
  end

  def find(request)
    nodes = client.get('nodes', "node:#{request.key}")
    nodes.each do |n|
      node = Puppet::Node.new(n.name)
      node.classes = n.tags.reject { |t| ! valid_tag?(t) }
      return node
    end
    return nil
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
end

# If this is executed directly, we want to support specification of
# a host.  If used this way, set 'node_terminus = /path/to/ckpuppet.rb'
# in puppet.conf.
#   Drop this into $RUBYLIB/puppet/indirector/node/cloudkick.rb to use
# as a plugin, then set 'node_terminus = cloudkick' in puppet.conf.
if $0 == __FILE__
  Puppet::Node.terminus_class = :cloudkick
  if node = Puppet::Node.find(ARGV[0])
    puts node.to_yaml
  else
    warn "Could not find #{ARGV[0]}"
    exit 1
  end
end
