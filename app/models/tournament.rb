class Tournament < ApplicationRecord
  PAGE_NAMES = [:register, :rules_and_regulations].freeze

  has_many :groups, dependent: :destroy
  has_many :matches, through: :groups
  has_many :pages
  has_many :players
  has_many :teams, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  after_create :generate_time_slots
  after_create :generate_pages

  private

  def generate_pages
    PAGE_NAMES.each do |p|
      I18n.available_locales.each do |l|
        pages.create name: p, locale: l
      end
    end
  end

  def generate_time_slots
    return unless start_date && end_date
    hour_range = Venue::OPENING_HOUR..Venue::CLOSING_HOUR
    (start_date..end_date).each do |date|
      Venue.find_each do |v|
        hour_range.each do |hour|
          new_time = Time.new(date.year, date.month, date.day, hour)
          Venue::CAPACITY.times do
            v.time_slots.create(time: new_time, available: true)
          end
        end
      end
    end
  end
end
