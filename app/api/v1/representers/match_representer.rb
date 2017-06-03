require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module MatchRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :time
      property :team_a
      property :team_b
      property :venue
      property :group

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.url}/#{id}"
      end
    end
  end
end
