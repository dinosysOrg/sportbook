require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module MatchesRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer
      collection :entries, as: :matches, embedded: true
    end
  end
end
