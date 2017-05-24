class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_USER_NAME')
  layout 'mailer'

  def mailer(email)
    mail(to: email, subject: 'Invitation')
  end
end
