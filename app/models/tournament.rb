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

  scope :in_two_day, -> { where('start_date > ? AND start_date < ?', Time.zone.now, 2.days.from_now) }

  def self.push_is_paid(user_ids)
    NotificationsService.push_notification(user_ids, I18n.t('tournament.push.push_is_paid'), 201)
  end

  def self.push_unpaid
    tournaments = Tournament.in_two_day.includes(:teams).references(:teams).where('teams.status = ?', 0)
    tournaments.each do |tournament|
      user_ids = tournament.players.pluck(:user_id)
      NotificationsService.push_notification(user_ids, I18n.t('tournament.push.push_unpaid', name: tournament.name), 202)
    end
  end

  def self.push_upcoming
    user_ids = Player.includes(:tournament).references(:tournament).in_two_day.pluck(:user_id)
    NotificationsService.push_notification(user_ids, I18n.t('tournament.push.push_upcoming'), 203)
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
