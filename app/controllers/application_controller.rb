class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  def access_denied(exception)
    redirect_to destroy_admin_user_session_path, method: :delete, alert: exception.message
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:address, :phone_number, :email, :name, :password,
                                                              :password_confirmation])
  end

  def set_locale
    I18n.locale = (params[:locale] || session[:locale] || I18n.default_locale).to_sym
    session[:locale] = I18n.locale
  end
end
