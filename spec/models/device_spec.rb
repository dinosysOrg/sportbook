require 'rails_helper'

RSpec.describe Device, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:token) }
  it { is_expected.to validate_presence_of(:platform) }
  it { is_expected.to validate_uniqueness_of(:token).scoped_to(:user_id) }
end
