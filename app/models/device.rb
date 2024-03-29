class Device < ApplicationRecord
  belongs_to :user

  enum platform: { ios: 0, android: 1 }

  validates :udid, presence: true, uniqueness: true
  validates :platform, presence: true, inclusion: { in: platforms }
  validates :token, presence: true, uniqueness: true
end
