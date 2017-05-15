class TournamentDecorator < ApplicationDecorator
  delegate :name

  def rules_and_regulations_page
    pages.where(name: :rules_and_regulations, locale: I18n.locale).first
  end

  def register_page
    pages.where(name: :register, locale: I18n.locale).first
  end

  private

  def pages
    object.pages
  end
end
