class TourVenue < ApplicationRecord
  belongs_to :tournament
  belongs_to :venue
end
