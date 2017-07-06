class NotificationsService
  class << self
    def push_notification(user_ids, message, code)
      ios_tokens = Device.where(user_id: user_ids).ios.pluck(:token)
      android_tokens = Device.where(user_id: user_ids).android.pluck(:token)

      IosNotificationsService.ios_push_notification(ios_tokens, message, code) if ios_tokens
      AndroidNotificationsService.android_push_notification(android_tokens, message, code) if android_tokens
    end
  end
end
