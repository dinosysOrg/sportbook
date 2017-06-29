require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module TimeBlocksRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :id
      property :name
      property :preferred_time_blocks
      property :venue_ranking

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
