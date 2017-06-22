require 'rails_helper'

RSpec.describe Team, type: :model do
  it { is_expected.to have_many(:groups_teams) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:tournament) }
end
