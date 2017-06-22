class IosNotificationsService
  class << self
    def ios_push_notification(ios_tokens, message, code)
      houston_push_notification(ios_tokens, message, code)
    end

    private

    def houston_push_notification(tokens, message, code)
      apn = Houston::Client.development
      apn.certificate = File.read(ENV.fetch('APPLE_CERTIFICATE')) # certificate from prerequisites
      tokens.each do |token|
        notification = Houston::Notification.new(device: token)
        notification.alert = message
        notification.badge = 1
        notification.sound = 'sosumi.aiff'
        notification.custom_data = { code: code }
        apn.push(notification)
      end
    end
  end
end
