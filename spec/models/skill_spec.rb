require 'rails_helper'

RSpec.describe Skill, type: :model do
  it { is_expected.to validate_presence_of(:name) }

  it 'validates uniqueness of name' do
    create :skill, name: 'professional'
    skill1 = Skill.new
    skill1.name = 'professional'
    expect(skill1).to_not be_valid
  end
end
