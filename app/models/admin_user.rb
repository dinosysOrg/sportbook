class AdminUser < User
  before_save :add_uid

  def add_uid
    uid = email if provider == 'email'
  end
end
