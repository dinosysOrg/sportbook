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
end
