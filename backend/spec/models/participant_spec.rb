require 'rails_helper'

RSpec.describe Participant, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tournament) }
  it { is_expected.to belong_to(:team) }

  it 'validates uniqueness of [:user_id, :team_id]' do
    user = create :user
    expect(Participant.new(user_id: user.id)).to validate_uniqueness_of(:user_id).scoped_to(:team_id)
  end
end
