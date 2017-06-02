class Device < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :platform, presence: true
  validates :token, presence: true, uniqueness: { scope: :user_id }

  before_save :downcase_platform

  scope :android, (-> { where(platform: 'android') })
  scope :ios, (-> { where(platform: 'ios') })

  private

  def downcase_platform
    self.platform = platform&.downcase
  end
end
