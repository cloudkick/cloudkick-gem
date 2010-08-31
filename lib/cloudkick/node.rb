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

  class MalformedRequest < StandardError
    def initialize(error)
      raise self, "Malformed API query: #{error}"
    end 
  end

  class ConnectionError < Exception
    def initialize(error_code, body)
      message = ""
      case error_code.to_i
        when 400 then message = "Bad Request"
        when 401 then message = "Unauthorized"
        when 402 then message = "Payment Required"
        when 403 then message = "Forbidden"
        when 404 then message = "Not Found"
        when 405 then message = "Method not allowed"
        when 406 then message = "Not Acceptable"
        when 407 then message = "Proxy Authentication Required"
        when 408 then message = "Request Timeout"
        when 409 then message = "Conflict"
        when 410 then message = "Gone"
        when 411 then message = "Length Required"
        when 412 then message = "Precondition Failed"
        when 413 then message = "Request Entity Too Large"
        when 414 then message = "Request-URI Too Long"
        when 415 then message = "Unsupported Media Type"
        when 416 then message = "Requested Range Not Satisfiable"
        when 417 then message = "Expectation Failed"
        when 500 then message = "Internal Server Error"
        when 501 then message = "Not Implemented"
        when 502 then message = "Bad Gateway"
        when 503 then message = "Service Unavailable"
        when 504 then message = "Gateway Timeout"
        when 505 then message = "HTTP Version Not Supported"
      end

      raise self, "[#{error_code}] - #{message} (#{body})"
    end
  end
  
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

    # We treat the checks as the nodes info. The standars of the
    # check queries are defined here:
    #
    # https://support.cloudkick.com/API/Query
    #
    def check(type=nil)
     
      if !type.match(/(mem|cpu|disk|plugin)(\/)?([A-Za-z0-9\_\-\.]*)?/)
        raise MalformedRequest, "Unknown type #{type}"
      end
      
      resp, data = access_token.get("/1.0/query/node/#{@id}/check/#{type}")

      if resp.code.to_i >= 400
        raise ConnectionError.new(resp.code, resp.body)
      end

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

      if resp.code.to_i >= 400
        raise ConnectionError.new(resp.code, resp.body)
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
