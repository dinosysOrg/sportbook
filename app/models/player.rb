class Player < ApplicationRecord
  belongs_to :user
  belongs_to :tournament
  belongs_to :team

  delegate :name, :phone_number, :email, to: :user

  validates :user_id, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
  def self.update_infomations(current_api_user, params)
    name = [params[:first_name], params[:last_name]].reject(&:empty?).join(' ')
    player = Player.find_by_id(params[:player_id])
    player.user.update_attributes!(name: name, password: params[:password],
                                   address: params[:address], birthday: params[:birthday], club: params[:club])
    player
  end

  def first_name
    user.first_name unless user.blank?
  end

  def last_name
    user.last_name unless user.blank?
  end
end
