require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:players) }
  it { is_expected.to belong_to(:skill) }
  it { is_expected.to have_many(:teams) }
  it { is_expected.to have_many(:tournaments) }
  it { is_expected.to have_many(:roles_users) }
  it { is_expected.to have_many(:devices) }
end
