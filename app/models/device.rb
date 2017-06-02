class Device < ApplicationRecord
  belongs_to :user

  enum platform: { ios: 0, android: 1 }

  validates :user_id, presence: true
  validates :platform, presence: true, inclusion: { in: platforms }
  validates :token, presence: true, uniqueness: { scope: :user_id }
end
