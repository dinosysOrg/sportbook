require 'rails_helper'

RSpec.describe Device, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:udid) }
  it { is_expected.to validate_presence_of(:token) }
  it { is_expected.to validate_presence_of(:platform) }
  it { is_expected.to validate_uniqueness_of(:token) }
  it { is_expected.to validate_uniqueness_of(:udid) }
end
