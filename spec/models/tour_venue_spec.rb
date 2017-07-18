require 'rails_helper'

RSpec.describe ToursVenue, type: :model do
  it { is_expected.to belong_to(:tournament) }
  it { is_expected.to belong_to(:venue) }
  it { is_expected.to validate_presence_of(:tournament) }
  it { is_expected.to validate_presence_of(:venue) }
end
