class Invitation < ApplicationRecord
  include AASM
  TIME_TO_RESPOND = 1.days
  belongs_to :invitee, class_name: 'Team'
  belongs_to :inviter, class_name: 'Team'
  belongs_to :match, counter_cache: true
  belongs_to :venue
  enum status: { created: 0, pending: 1, accepted: 2, rejected: 3, expired: 4 }

  validates :invitee, presence: true
  validates :inviter, presence: true
  validates :match, presence: true
  validates :status, presence: true
  validates :time, presence: true
  validates :venue, presence: true

  validate :check_invitation_count
  validate :check_existing_pending_invitation, on: :create
  validate :check_time_slot_avaible, on: [:create, :update]

  aasm column: :status, enum: true do
    state :created, initial: true
    state :pending
    state :accepted
    state :rejected
    state :expired

    event :sent do
      transitions from: :created, to: :pending
    end

    event :expire, after_commit: :update_point_for_winner do
      transitions from: :pending, to: :expired
    end

    event :accept, after_commit: :update_timeslot_and_match do
      transitions from: :pending, to: :accepted
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  def self.validate_deadline
    pending_invitations = Invitation.pending
    pending_invitations.each do |invitation|
      invitation.expire! if invitation.created_at + TIME_TO_RESPOND <= Time.zone.now
    end
  end

  def validate_deadline_for_api
    expire! if created_at + Invitation::TIME_TO_RESPOND <= Time.zone.now
  end

  def check_time_slot_avaible
    return unless time && venue_id
    available_time_slots = TimeSlot.where(time: time, object_id: venue_id, available: true)
    return unless available_time_slots.empty?

    add_time_slot_pick_error
  end

  private

  def update_point_for_winner
    if match.team_a_id == invitee_id
      match.update_attribute('point_b', 3)
    elsif match.team_b_id == invitee_id
      match.update_attribute('point_a', 3)
    end
    errors.add(:status, :expired)
  end

  def update_timeslot_and_match
    venue.time_slots.first.update_attribute('available', false)
    update_status_timeslot(time, invitee, false)
    update_status_timeslot(time, inviter, false)
    Match.find(match_id).update_attribute('time', time)
  end

  def check_invitation_count
    return unless match_id
    count_invitation = Match.find(match_id).invitations_count
    return unless count_invitation >= Match::MAX_INVITATIONS_COUNT

    add_invation_error
  end

  def check_existing_pending_invitation
    return unless match_id

    last_invitation = match.invitations.pending.first
    return unless last_invitation

    errors.add(:match_id, :pending_invitation_exists)
  end

  private

  def update_status_timeslot(time, object, status)
    TimeSlot.find_by(time: time, object: object)
            .update_attribute('available', status)
  end

  def add_invation_error
    errors.add(:match_id,
               :count_full,
               max: Match::MAX_INVITATIONS_COUNT)
  end

  def add_time_slot_pick_error
    errors.add(:time, :slot_picked)
  end
end
