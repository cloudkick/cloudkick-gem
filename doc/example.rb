require 'rubygems'
require 'cloudkick'

CONSUMER_KEY = 'ENTER_KEY'
CONSUMER_SECRET = 'ENTER_SECRET'

client = Cloudkick::Base.new(CONSUMER_KEY,
                             CONSUMER_SECRET)

agent_nodes = client.get('nodes', 'tag:agent')
nodes = client.get('nodes')

nodes.each do |node|
  puts "#{node.name}: #{node.status}"
end

# puts
# puts nodes.pssh('hostname')

# agent_nodes do |node|
#   puts node.check('mem')
# end
