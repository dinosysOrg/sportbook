require 'rails_helper'

RSpec.describe TourVenue, type: :model do
  it { is_expected.to belong_to(:tournament) }
  it { is_expected.to belong_to(:venue) }
end
