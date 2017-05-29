class Invitation < ApplicationRecord
  include AASM
  DEADLINE = 1.days
  belongs_to :invitee, class_name: 'Team'
  belongs_to :inviter, class_name: 'Team'
  belongs_to :match, counter_cache: true
  belongs_to :venue
  enum status: { created: 0, pending: 1, accepted: 2, rejected: 3, forfeited: 4 }

  validates :invitee, presence: true
  validates :inviter, presence: true
  validates :match, presence: true
  validates :status, presence: true
  validates :time, presence: true
  validates :venue, presence: true

  validate :check_invitation_count
  validate :check_existing_pending_invitation, on: :create

  aasm column: :status, enum: true do
    state :created, initial: true
    state :pending
    state :accepted
    state :rejected
    state :forfeited

    event :tranform_pending do
      transitions from: :created, to: :pending
    end

    event :forfeit do
      transitions from: :pending, to: :forfeited
    end

    event :accept, after_commit: :update_time_for_match do
      transitions from: :pending, to: :accepted
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  def self.validate_deadline
    pending_invitations = Invitation.pending
    pending_invitations.each do |invitation|
      invitation.forfeit! if invitation.created_at + DEADLINE <= DateTime.now
    end
  end

  private
  
  def update_time_for_match
    match = Match.find(match_id)
    match.update_attributes!(time: time)
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

  def add_invation_error
    errors.add(:match_id,
               :count_full,
               max: Match::MAX_INVITATIONS_COUNT)
  end
end
