require 'rails_helper'

RSpec.describe Invitation, type: :model do
  it { is_expected.to validate_presence_of(:match) }
  it { is_expected.to validate_presence_of(:invitee) }
  it { is_expected.to validate_presence_of(:inviter) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:time) }
  it { is_expected.to validate_presence_of(:venue) }

  describe 'Validation' do
    let(:venue) { create(:venue) }
    let(:match) { create(:match) }
    let!(:time_slot) { create(:time_slot, object: venue, available: true) }

    describe 'creating Invitation' do
      it 'does not allow more than max invitations for each match' do
        Match::MAX_INVITATIONS_COUNT.times do
          create :invitation, :created, match: match, venue: venue
        end
        extra_invitation = match.invitations.build
        expect(extra_invitation).to_not be_valid
        expect(extra_invitation.errors[:match_id]).to include('There can be only 3 invitations for each match')
      end

      it 'does not allow creating new invitation if there is already a pending one' do
        create :invitation, :pending, match: match, venue: venue
        new_invitation = match.invitations.build
        expect(new_invitation).to_not be_valid
        expect(new_invitation.errors[:match_id]).to include('There is one pending invitation')
      end
    end

    describe 'validate status' do
      it 'checkes status' do
        invitation = Invitation.new
        expect(invitation).to transition_from(:pending).to(:accepted).on_event(:accept)
        expect(invitation).to transition_from(:pending).to(:rejected).on_event(:reject)
        expect(invitation).not_to transition_from(:pending).to(:accepted).on_event(:reject)
        expect(invitation).not_to transition_from(:pending).to(:rejected).on_event(:accept)
      end

      it 'will raise error when trying to update status when its already rejected/approved' do
        invitation = create :invitation, :accepted, venue: venue
        expect { invitation.reject }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'validate deadline for pending inivation' do
      let!(:rejected_invitation) { create_list(:invitation, 2, :rejected, created_at: 1.days.ago.at_beginning_of_hour, venue: venue) }
      it 'check deadline with time is less than now' do
        invitations = create_list(:invitation, 2, :pending, created_at: 1.days.ago.at_beginning_of_hour, venue: venue)
        Invitation.validate_deadline
        expect(invitations.first.reload).to be_expired
        expect(invitations.last.reload).to be_expired
      end

      it 'check deadline with time is greater than now' do
        invitations = create_list(:invitation, 2, :pending, created_at: 1.days.from_now.at_beginning_of_hour, venue: venue)
        Invitation.validate_deadline
        expect(invitations.first.reload).to be_pending
        expect(invitations.last.reload).to be_pending
      end
    end

    describe 'update match status' do
      it 'updates match when invitation is expired' do
        team_a = create :team
        team_b = create :team
        match = create :match, team_a: team_a, team_b: team_b
        invitation = create :invitation, :pending, venue: venue, match: match, invitee: team_a, inviter: team_b
        invitation.expire!
        expect(match.reload.point_b).to eq(3)
        expect(match.reload.point_a).to eq(0)
      end
    end
  end

  describe 'accept' do
    let(:match) { create :match, time: nil, venue: nil }
    let(:pending_invitation) do
      create :invitation, :pending, time: time_slot_venue.time, match: match, venue: venue, invitee: match.team_a, inviter: match.team_b
    end
    let(:venue) { create(:venue) }
    let!(:time_slot_venue) { create(:time_slot, object: venue, available: true) }
    let!(:time_slot_invitee) { create(:time_slot, object: match.team_a, available: true) }

    it 'updates time slots' do
      time_slot_inviter = create(:time_slot, object: pending_invitation.inviter, available: true)

      pending_invitation.accept!

      time_slot_venue.reload
      time_slot_invitee.reload
      time_slot_inviter.reload

      expect(time_slot_venue).to_not be_available
      expect(time_slot_venue.match_id).to eq(match.id)

      expect(time_slot_invitee).to_not be_available
      expect(time_slot_invitee.match_id).to eq(match.id)

      expect(time_slot_inviter).to_not be_available
      expect(time_slot_inviter.match_id).to eq(match.id)
    end

    it 'updates match' do
      pending_invitation.accept!

      match.reload
      expect(match.time).to eq(pending_invitation.time)
      expect(match.venue).to eq(venue)
    end

    context 'when inviter does not have a time slot' do
      it 'creates a new time slot for inviter' do
        expect { pending_invitation.accept! }.to change(TimeSlot, :count).by(1)

        inviter = pending_invitation.inviter
        time_slot_inviter = inviter.time_slots.find_by(time: pending_invitation.time)
        expect(time_slot_inviter).to_not be_available
      end
    end
  end
end
