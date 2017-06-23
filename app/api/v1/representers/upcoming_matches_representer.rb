require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module UpcomingMatchesRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      collection :this_week, extend: MatchRepresenter, as: :matches_this_week, embedded: true
      collection :next_week, extend: MatchRepresenter, as: :matches_next_week, embedded: true

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
