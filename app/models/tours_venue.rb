class ToursVenue < ApplicationRecord
  validates :tournament, presence: true
  validates :venue, presence: true
  belongs_to :tournament
  belongs_to :venue
end
