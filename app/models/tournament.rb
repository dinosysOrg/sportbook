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

    date_range = self.start_date..self.end_date
    hour_range = 9..24
    for date in date_range
      Venue.find_each do |v|
        hour_range.each do |hour|
         new_time = Time.new(date.year,date.month,date.day,hour)
         puts new_time
         2.times do
          v.time_slots.create(time: new_time,available: true)
         end
       end
      end
    end
    debugger
  end
end
