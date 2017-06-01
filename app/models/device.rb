class Device < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :platform, presence: true
  validates :token, presence: true, uniqueness: { scope: :user_id }
end
