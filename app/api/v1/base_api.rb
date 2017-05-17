module V1
  class BaseApi < Grape::API
    content_type :hal, 'application/hal+json'
    content_type :json, 'application/json'

    formatter :json, Grape::Formatter::Roar
    formatter :hal, Grape::Formatter::Roar

    helpers ExceptionHandlers

    rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record!
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found!
    rescue_from Grape::Exceptions::ValidationErrors, with: :handle_validation_errors!
    rescue_from :all, with: :handle_unexpected_errors!
  end
end
