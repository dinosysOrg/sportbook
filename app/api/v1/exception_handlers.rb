module V1
  module ExceptionHandlers
    def handle_invalid_record!(e)
      errors = e.record.errors.messages.map do |attr, messages|
        messages.map { |message| { attribute: attr, message: message } }
      end.flatten
      error!(
        { errors: errors, status_code: 422 },
        422
      )
    end

    def handle_record_not_found!(e)
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

    def handle_validation_errors!(e)
      errors = e.errors.map do |k, v|
        { message: v.first, attribute: k.first }
      end
      error!(
        { errors: errors, status_code: 422 },
        422
      )
    end

    def handle_unexpected_errors!(e)
      raise e if Rails.env.development? || Rails.env.test?

      error!(
        { errors: [{ message: 'Unexpected error happened on server' }], status_code: 500 },
        500
      )
      # TODO
      # error notification: Rollbar...
    end

    def handle_authorization_errors!(_)
      if current_api_user.nil?
        error!(
          { errors: [{ message: 'Login required' }], status_code: 401 },
          401
        )
      else
        error!(
          { errors: [{ message: 'Forbidden' }], status_code: 403 },
          403
        )
      end
    end
  end
end
