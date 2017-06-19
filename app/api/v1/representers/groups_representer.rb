require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module GroupsRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :my_groups
      property :other_groups

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
