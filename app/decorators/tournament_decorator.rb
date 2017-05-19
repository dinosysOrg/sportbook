class TournamentDecorator < ApplicationDecorator
  delegate :name, :players, :matches

  def rules_and_regulations_page
    pages.where(name: :rules_and_regulations, locale: I18n.locale).first
  end

  def register_page
    pages.where(name: :register, locale: I18n.locale).first
  end

  def groups_data
    GroupsDecorator.decorate object.groups.round_robin
  end

  private

  def pages
    object.pages
  end
end
