class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SMTP_USER_NAME')
  layout 'mailer'

  def invitation_mail(emails)
    mail(to: emails, subject: 'Invitation')
  end
end
