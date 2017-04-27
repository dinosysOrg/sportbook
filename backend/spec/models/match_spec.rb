require 'rails_helper'

RSpec.describe Match, type: :model do
  it { is_expected.to validate_presence_of(:group) }

  describe 'callbacks' do
    shared_examples 'calls :recalculate_statistics on all groups_teams' do |method|
      let(:match) { create(:match) }
      specify do
        match.groups_teams.each do |groups_team|
          expect(groups_team).to receive(:recalculate_statistics)
        end
        match.send(method)
      end
    end

    context 'after_save' do
      include_examples 'calls :recalculate_statistics on all groups_teams', :save
    end

    context 'after_destroy' do
      include_examples 'calls :recalculate_statistics on all groups_teams', :destroy
    end
  end
end
