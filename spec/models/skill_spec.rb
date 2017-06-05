require 'rails_helper'

RSpec.describe Skill, type: :model do
  it { is_expected.to validate_presence_of(:name) }

  it 'validates uniqueness of name' do
    skill1 = Skill.new
    skill1.name = 'Professional'
    expect(skill1).to_not be_valid
  end
end
