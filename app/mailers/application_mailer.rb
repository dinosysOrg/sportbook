class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@sportbook.vn'
  layout 'mailer'

  def invitation_mail(emails)
    mail(to: emails, subject: 'Invitation')
  end
end
