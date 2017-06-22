require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module TeamRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :id
      property :name
      property :players
      property :users

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.url}/#{id}"
      end
    end
  end
end
