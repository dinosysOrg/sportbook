module V1
  class BaseApi < Grape::API
    content_type :hal, 'application/hal+json'
    content_type :json, 'application/json'

    formatter :json, Grape::Formatter::Roar
    formatter :hal, Grape::Formatter::Roar
  end
end
