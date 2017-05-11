class Venue < ApplicationRecord
  has_many :matches
  has_many :time_slots

  auto_strip_attributes :google_calendar_name

  validates :name, presence: true, uniqueness: true
end
