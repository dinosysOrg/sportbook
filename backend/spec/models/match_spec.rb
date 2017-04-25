require 'rails_helper'

RSpec.describe Match, type: :model do
  it { is_expected.to validate_presence_of(:group) }
end
