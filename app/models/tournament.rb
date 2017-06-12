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

  def self.registration_confirmed(user_ids)
    message = I18n.t('tournament.push.registration_confirmed')
    NotificationsService.push_notification(user_ids, message)
  end

  def self.registered(user_ids)
    message = I18n.t('tournament.push.registered')
    NotificationsService.push_notification(user_ids, message)
  end

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
