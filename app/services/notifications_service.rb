class NotificationsService
  class << self
    require 'gcm'

    def push_notification(user_ids, message)
      ios_tokens = Device.where(user_id: user_ids).ios.pluck(:token)
      android_tokens = Device.where(user_id: user_ids).android.pluck(:token)

      ios_push_notification(ios_tokens, message) if ios_tokens
      android_push_notification(android_tokens, message) if android_tokens
    end

    private

    def ios_push_notification(tokens, message)
      apn = Houston::Client.development
      apn.certificate = File.read(ENV['APPLE_CERTIFICATE']) # certificate from prerequisites
      tokens.each do |token|
        notification = Houston::Notification.new(device: token)
        notification.alert = message
        notification.badge = 1
        notification.sound = 'sosumi.aiff'
        apn.push(notification)
      end
    end

    def android_push_notification(tokens, message)
      gcm = GCM.new(ENV['API_KEY']) # an api key from prerequisites
      options = {
        data: {
          message: message
        },
        collapse_key: collapse_key || 'my_app'
      }
      _response = gcm.send(tokens, options)
    end
  end
end
