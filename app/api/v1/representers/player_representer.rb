require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module PlayerRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :user, class: User do
        property :first_name
        property :last_name
        property :address
        property :birthday
        property :club
      end

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
