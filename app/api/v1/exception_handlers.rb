module V1
  module ExceptionHandlers
    extend ActiveSupport::Concern

    included do
      rescue_from ActiveRecord::RecordInvalid do |e|
        errors = e.record.errors.messages.map do |attr, messages|
          messages.map { |message| { attribute: attr, message: message } }
        end.flatten
        error!(
          { errors: errors, status_code: 422 },
          422
        )
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        errors = [
          message: e.message,
          model: e.model,
          attribute: e.primary_key,
          value: e.send(e.primary_key)
        ]
        error!(
          { errors: errors, status_code: 404 },
          404
        )
      end

      rescue_from Grape::Exceptions::ValidationErrors do |e|
        errors = e.errors.map do |k, v|
          { message: v.first, attribute: k.first }
        end
        error!(
          { errors: errors, status_code: 422 },
          422
        )
      end

      rescue_from :all do |e|
        raise e if Rails.env.development? || Rails.env.test?

        error!(
          { errors: [{ message: 'Unexpected error happened on server' }], status_code: 500 },
          500
        )
        # TODO
        # error notification: Rollbar...
      end
    end
  end
end
