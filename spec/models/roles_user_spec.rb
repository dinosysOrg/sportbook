require 'rails_helper'

RSpec.describe RolesUser, type: :model do
  it { is_expected.to belongs_to(:user) }
  it { is_expected.to belongs_to(:role) }
end
