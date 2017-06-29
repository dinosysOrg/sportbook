require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module PossibleTimeSlotsRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      collection :entries, as: :venues, embedded: true do
        property :id
        property :name
        collection :time_slots
        collection :time_blocks
      end

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
