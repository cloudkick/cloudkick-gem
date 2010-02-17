require 'cloudkick'

# cloudkick
CONSUMER_KEY = 'sRgsZZwtmn7ksX5a'
CONSUMER_SECRET = 'VthUpnQu3qQJ6gGp'

# marktran
# CONSUMER_KEY = 'FT4DX7BRtkabVna4'
# CONSUMER_SECRET = '4RAF5SLq4A77wvqn'

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
