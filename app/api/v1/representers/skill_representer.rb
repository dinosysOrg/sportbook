require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module SkillRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :id
      property :name

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.url}/#{id}"
      end
    end
  end
end
