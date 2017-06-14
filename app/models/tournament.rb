class Tournament < ApplicationRecord
  PAGE_NAMES = [:register, :rules_and_regulations].freeze

  active_admin_translates :competition_mode, :competition_fee, :competition_schedule

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
    date_range = start_date..end_date
    TimeSlotService.create_from_date_and_hour_range(Venue.all.to_a, hour_range, date_range)
  end
end
