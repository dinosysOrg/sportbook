require 'rails_helper'

RSpec.describe Venue, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:lat) }
  it { is_expected.to validate_presence_of(:long) }
  it { is_expected.to validate_uniqueness_of(:name) }

  it 'strips calendar' do
    venue = create :venue
    venue.google_calendar_name = "83843uref nkfhfkahsfsd   \t\r\n\n"
    venue.validate
    expect(venue.google_calendar_name).to eq('83843uref nkfhfkahsfsd')
  end
end
