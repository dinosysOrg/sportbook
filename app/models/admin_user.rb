class AdminUser < User
  before_save :add_uid

  def add_uid
    self.uid = email if provider == 'email'
  end
end
