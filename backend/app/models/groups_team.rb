class GroupsTeam < ApplicationRecord
  belongs_to :group
  belongs_to :team

  delegate :name, :phone_numbers, to: :team

  def matches_as_team_a
    team.matches_as_team_a.where(group_id: group.id)
  end

  def matches_as_team_b
    team.matches_as_team_b.where(group_id: group.id)
  end

  def points
    points_as_team_a = matches_as_team_a.sum(:point_a)
    points_as_team_b = matches_as_team_b.sum(:point_b)
    points_as_team_a + points_as_team_b
  end

  def draws
    count(:draw)
  end

  def losses
    count(:lose)
  end

  def wins
    count(:win)
  end

  def score_difference
    score_difference_as_team_a = matches_as_team_a.sum(:score_a) - matches_as_team_a.sum(:score_b)
    score_difference_as_team_b = matches_as_team_b.sum(:score_b) - matches_as_team_b.sum(:score_a)
    score_difference_as_team_a + score_difference_as_team_b
  end

  private

  def count(situation)
    as_team_a = matches_as_team_a.where(point_a: Match::POINTS[situation]).count
    as_team_b = matches_as_team_b.where(point_b: Match::POINTS[situation]).count
    as_team_a + as_team_b
  end
end
