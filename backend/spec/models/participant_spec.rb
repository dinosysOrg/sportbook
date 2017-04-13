require 'rails_helper'

RSpec.describe Participant, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tournament) }

  it 'validates uniqueness of [:user_id, :tournament_id]' do
    user = create :user
    expect(Participant.new(user_id: user.id)).to validate_uniqueness_of(:user_id).scoped_to(:tournament_id)
  end
end
