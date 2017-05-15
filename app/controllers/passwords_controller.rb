class PasswordsController < DeviseTokenAuth::PasswordsController
  def edit
    super do
      redirect_url          = URI.parse(params[:redirect_url])
      reset_params          = { reset_password_token: @resource.reset_password_token }
      redirect_url.query    = Rack::Utils.parse_query(redirect_url.query).merge(reset_params).to_query
      params[:redirect_url] = redirect_url.to_s

      # Devise's reset_password_by_token sets the @resource's +reset_password_token+ attribute
      # to its raw value after performing a database lookup. Due to devise_token_auth's +save!+
      # to persist the newly generate auth token, the raw value is written to the database.
      # This causes a recovery link to be only valid once, even if no new password was specified
      # as well as an inconsistency to Device's use of `token_generator.digest`
      @resource.reset_password_token = Devise.token_generator.digest(@resource, :reset_password_token,
                                                                     @resource.reset_password_token)
      @resource.save(validate: false)
    end
  end

  protected

  def resource_update_method
    # Only allow setting a new password without specifying the current one if the user
    # is currently in the middle of a password recovery process and the client passed
    # in his current +password_reset_token+
    @resource.allow_password_change = valid_reset_password_token?
    super
  end

  #
  # Checks whether a password reset token is given and if it matches the current user
  #
  def valid_reset_password_token?
    return false if @resource.reset_password_token.blank? || @resource.reset_password_token.blank?
    digest = Devise.token_generator.digest(@resource, :reset_password_token, resource_params[:reset_password_token])
    digest == @resource.reset_password_token
  end
end
