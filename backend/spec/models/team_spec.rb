require 'rails_helper'

RSpec.describe Team, type: :model do
  it { is_expected.to have_and_belong_to_many(:groups) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:tournament_id).case_insensitive }
end
