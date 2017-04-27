require 'rails_helper'

RSpec.describe Player, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tournament) }
  it { is_expected.to belong_to(:team) }

  it 'validates uniqueness of [:user_id, :team_id]' do
    user = create :user
    expect(Player.new(user_id: user.id)).to validate_uniqueness_of(:user_id).scoped_to(:tournament_id)
  end
end
