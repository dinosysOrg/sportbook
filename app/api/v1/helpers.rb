module V1
  module Helpers
    extend Grape::API::Helpers

    def set_locale_api
      I18n.locale = (params[:locale] || I18n.default_locale).to_sym
    end
  end
end
