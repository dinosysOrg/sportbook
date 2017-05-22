require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module SkillsRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      collection :entries, extend: SkillRepresenter, as: :skills, embedded: true

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
