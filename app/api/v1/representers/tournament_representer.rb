require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module TournamentRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :name
      property :start_date
      property :end_date

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.url}/#{id}"
      end
    end
  end
end
