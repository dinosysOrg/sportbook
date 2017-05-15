class Venue < ApplicationRecord
  OPENING_HOUR = 9
  CLOSING_HOUR = 24
  CAPACITY = 2
  has_many :matches
  has_many :time_slots
  auto_strip_attributes :google_calendar_name

  validates :name, presence: true, uniqueness: true
end
