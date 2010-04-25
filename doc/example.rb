require 'rubygems'
require 'cloudkick'

# your OAuth consumer credentials.
# https://support.cloudkick.com/API/Authentication#Generating_OAuth_Consumers
CONSUMER_KEY = 'ENTER_KEY'
CONSUMER_SECRET = 'ENTER_SECRET'

client = Cloudkick::Base.new(CONSUMER_KEY,
                             CONSUMER_SECRET)

# get all nodes and print name and status
nodes = client.get('nodes')
nodes.each do |node|
  puts "#{node.name}: #{node.status}"
end

# get all nodes tagged "agent" and print memory information
agent_nodes = client.get('nodes', 'tag:agent')
agent_nodes do |node|
  puts node.check('mem')
end
