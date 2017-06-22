class AndroidNotificationsService
  class << self
    def android_push_notification(android_tokens, message, code)
      gcm_push_notification(android_tokens, message, code)
    end

    private

    def gcm_push_notification(tokens, message, code)
      gcm = GCM.new(ENV.fetch('GOOGLE_API_KEY')) # an api key from prerequisites
      options = {
        data: {
          message: message,
          code: code
        },
        collapse_key: 'my_app'
      }
      _response = gcm.send(tokens, options)
    end
  end
end
