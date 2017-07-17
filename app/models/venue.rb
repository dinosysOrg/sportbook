class Venue < ApplicationRecord
  OPENING_HOUR = 9
  CLOSING_HOUR = 24
  CAPACITY = 2
  has_many :matches
  has_many :time_slots, as: :object
  auto_strip_attributes :google_calendar_name

  validates :name, presence: true, uniqueness: true
  validates :lat, presence: true
  validates :long, presence: true
end
