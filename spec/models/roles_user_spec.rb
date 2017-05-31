require 'rails_helper'

RSpec.describe RolesUser, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:role) }
end
