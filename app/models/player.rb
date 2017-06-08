class Player < ApplicationRecord
  belongs_to :user
  belongs_to :tournament
  belongs_to :team

  delegate :name, :phone_number, :email, to: :user

  validates :user_id, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
  def self.update_infomations(params)
    name = params[:first_name]
    name << params[:last_name]
    player = Player.find_by_id(params[:player_id])
    player.user.update_attributes!(email: params[:email], name: name, password: params[:password],
                                   address: params[:address], birthday: params[:birthday])
  end

  def first_name
    user.first_name unless user.blank?
  end

  def last_name
    user.last_name unless user.blank?
  end

  def email
    user.email unless user.blank?
  end

  def address
    user.address unless user.blank?
  end

  def birthday
    user.birthday unless user.blank?
  end
end
