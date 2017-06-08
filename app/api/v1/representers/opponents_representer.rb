require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module OpponentsRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      collection :entries, as: :opponents, embedded: true do
        property :team_id
        property :team_name
        property :invitation_id
        property :invitation_status
        property :invitation_invitee_id
        property :invitation_inviter_id
      end

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        request.url
      end
    end
  end
end
