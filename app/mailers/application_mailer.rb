class ApplicationMailer < ActionMailer::Base
  default from: ENV['SMTP_USER_NAME'].presence || 'from@example.com'
  layout 'mailer'

  def invitation_mail(emails)
    mail(to: emails, subject: 'Invitation')
  end
end
