require 'roar/json/hal'
require 'roar/hypermedia'

module V1
  module Representers
    module InvitationRepresenter
      include Roar::JSON::HAL
      include Roar::Hypermedia
      include Grape::Roar::Representer

      property :time
      property :status
      property :invitee
      property :inviter
      property :venue
      property :match

      link :self do |opts|
        request = Grape::Request.new(opts[:env])
        "#{request.url}"
      end
    end
  end
end
