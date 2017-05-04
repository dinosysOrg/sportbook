require 'rails_helper'

RSpec.describe GroupsTeam, type: :model do
  it { is_expected.to validate_presence_of(:group) }
  it { is_expected.to validate_presence_of(:team) }

  describe 'callbacks' do
    context 'after_save' do
      let(:groups_team) { create(:groups_team) }
      it 'calls :recalculate_statistics on all groups_teams' do
        expect(groups_team).to receive(:calculate_statistics)
        groups_team.save
      end
    end
  end

  describe 'calculate_statistics' do
    it 'calculates correct statistics' do
      groups_team = create(:groups_team)
      group = groups_team.group
      team = groups_team.team

      another_groups_team = create(:groups_team, team: team)
      another_group = another_groups_team.group

      create :match, group: group, team_a: team, point_a: 3, point_b: 0, score_a: 5, score_b: 1
      create :match, group: group, team_b: team, point_a: 1, point_b: 1, score_a: 3, score_b: 3
      create :match, group: group, team_a: team, point_a: 0, point_b: 3, score_a: 1, score_b: 3

      create :match, group: another_group, team_a: team, point_a: 3
      create :match, group: another_group, team_b: team, point_b: 3

      groups_team.reload
      expect(groups_team.points).to eq(4)
      expect(groups_team.score_difference).to eq(2)
      expect(groups_team.wins).to eq(1)
      expect(groups_team.draws).to eq(1)
      expect(groups_team.losses).to eq(1)
    end
  end
end
