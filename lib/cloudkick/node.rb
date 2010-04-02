# Copyright 2010 Cloudkick, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require 'crack'
require 'uri'

module Cloudkick
  class Node < Base

    attr_reader :agent_state, :color, :id, :ipaddress, :name
    attr_reader :provider_id, :provider_name, :status, :tags

    def initialize(agent_state, color, id, ipaddress, name,
                   provider_id, provider_name, status, tags)
      @agent_state = agent_state
      @color = color
      @id = id
      @ipaddress = ipaddress
      @name = name
      @provider_id = provider_id
      @provider_name = provider_name
      @status = status
      @tags = tags
    end

    def check(type=nil)
      resp, data = access_token.get("/1.0/query/node/#{@id}/check/mem")

      Crack::JSON.parse(data)
    end
  end

  class Nodes < Base
    
    attr_reader :nodes, :query
    
    def initialize(query=nil)
      @query = query
      @nodes = get
    end

    def each
      @nodes.each { |node| yield node }
    end
    
    def get
      if @query
        escaped = URI.escape(@query)
        resp, data = access_token.get("/1.0/query/nodes?query=#{escaped}")
      else
        resp, data = access_token.get("/1.0/query/nodes")        
      end

      hash = Crack::JSON.parse(data)
      nodes = hash.map do |node|
        Node.new(node['agent_state'], node['color'], node['id'],
                 node['ipaddress'], node['name'], node['provider_id'],
                 node['provider_name'], node['status'], node['tags'])
      end
    end

  end
end
