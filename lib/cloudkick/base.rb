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
require 'oauth'
require 'openssl'

# hack for certificate verification failure
module OpenSSL
  module SSL
    remove_const :VERIFY_PEER
  end
end

module Cloudkick
  class Base
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    def initialize(consumer_key, consumer_secret)
      @@key = consumer_key
      @@secret = consumer_secret
    end

    def consumer
      @@consumer ||= OAuth::Consumer.new(@@key, @@secret,
                                        :site => 'https://api.cloudkick.com',
                                        :http_method => :get)
    end

    def access_token
      @@access_token ||= OAuth::AccessToken.new(consumer)
    end

    def get(type, query=nil)
      if type == 'nodes'
        Cloudkick::Nodes.new(query)
      end
    end
  end
end
