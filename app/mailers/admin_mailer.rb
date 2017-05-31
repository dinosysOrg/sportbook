class AdminMailer < ApplicationMailer
  def notify_unconfirmed_matches(matches)
    emails = Role.admin_role.users.pluck(:email).uniq
    return if emails.empty?

    @groups = matches.group_by(&:group)

    mail(to: emails)
  end
end
