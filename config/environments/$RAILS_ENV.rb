config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'example.com',
  user_name:            'testmaildinosys@gmail.com',
  password:             'Dino123456789',
  authentication:       'plain',
  enable_starttls_auto: true  }