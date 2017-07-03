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
  validate :check_time_slot_avaible

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
    event :expire_after_reject, after_commit: :update_point_for_winner do
      transitions from: :rejected, to: :expired
    end
    event :accept, after_commit: :update_time_slot_and_match do
      transitions from: :pending, to: :accepted
    end
    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  def self.push_rejected(user_ids)
    NotificationsService.push_notification(user_ids, I18n.t('invitation.push.push_rejected'), 101)
  end

  def self.push_accepted(user_ids)
    NotificationsService.push_notification(user_ids, I18n.t('invitation.push.push_accepted'), 102)
  end

  def self.push_sent(user_ids)
    NotificationsService.push_notification(user_ids, I18n.t('invitation.push.push_sent'), 103)
  end

  def self.push_expired(user_ids)
    NotificationsService.push_notification(user_ids, I18n.t('invitation.push.push_expired'), 104)
  end

  def self.validate_deadline
    pending_invitations = Invitation.pending
    pending_invitations.each do |invitation|
      Invitation.push_rejected(invitation.invitee.user_ids) if invitation.expire! && invitation.created_at + TIME_TO_RESPOND <= Time.zone.now
    end
  end

  def self.check_reject_invitation(match_id = 0)
    rejected_invitations = match_id.zero? ? Invitation.rejected : Invitation.rejected.where(match_id: match_id)
    rejected_invitations.where.not(status: 'pending').each do |invitation|
      invitation.expire_after_reject! if invitation.created_at + TIME_TO_RESPOND > Time.zone.now
    end
  end

  def validate_deadline_for_api
    expire! if created_at + Invitation::TIME_TO_RESPOND <= Time.zone.now
  end

  def check_time_slot_avaible
    return unless time || venue_id || TimeSlot.where(time: time, object_id: venue_id, available: true).empty?
    errors.add(:time, :slot_picked)
  end

  def self.latest_invitation_between(invitee, inviter)
    Invitation.where('(inviter_id = ? AND invitee_id = ?) OR (invitee_id = ? AND inviter_id = ?)', invitee.id, inviter.id, invitee.id, inviter.id).last
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

  def update_time_slot_and_match
    TimeSlot.find_or_create_by!(time: time, object: inviter) { |t| t.available = true }

    update_status_time_slot(venue)
    update_status_time_slot(invitee)
    update_status_time_slot(inviter)
    match.update_attributes!(time: time, venue: venue)
  end

  def check_invitation_count
    return unless match_id || match.invitations_count >= Match::MAX_INVITATIONS_COUNT
    errors.add(:match_id, :count_full, max: Match::MAX_INVITATIONS_COUNT)
  end

  def check_existing_pending_invitation
    return unless match_id || match.invitations.pending.first
    errors.add(:match_id, :pending_invitation_exists)
  end

  def update_status_time_slot(object)
    object.time_slots.find_by(time: time, available: true).update_attributes!(available: false, match_id: match_id)
  end
end
