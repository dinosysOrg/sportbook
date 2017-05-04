class Venue < ApplicationRecord
  has_many :matches

  auto_strip_attributes :google_calendar_name

  validates :name, presence: true, uniqueness: true
end
