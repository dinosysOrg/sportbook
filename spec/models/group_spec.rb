require 'rails_helper'

RSpec.describe Group, type: :model do
  it { is_expected.to have_many(:groups_teams) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:tournament) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:tournament_id).case_insensitive }
end
