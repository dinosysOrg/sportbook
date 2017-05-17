class Tournament < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :players
  has_many :matches, through: :groups

  validates :name, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  after_create :generate_time_slots

  private

  def generate_time_slots
    return unless start_date && end_date
    hour_range = Venue::OPENING_HOUR..Venue::CLOSING_HOUR
    date_range = start_date..end_date
    TimeSlotService.instance.create_from_date_and_hour_range(Venue.all.to_a, hour_range, date_range)
  end
end
