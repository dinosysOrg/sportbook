class GroupsTeam < ApplicationRecord
  belongs_to :group
  belongs_to :team

  validates :team, presence: true
  validates :group, presence: true

  before_save :calculate_statistics

  default_scope { order(points: :desc, score_difference: :desc, order: :asc) }

  delegate :name, :phone_numbers, to: :team

  def recalculate_statistics
    calculate_statistics
    save
  end

  private

  def calculate_statistics
    self.points = calculate_points
    self.score_difference = calculate_score_difference
    self.wins = calculate_wins
    self.draws = calculate_draws
    self.losses = calculate_losses
  end

  def matches_as_team_a
    return Match.none unless team
    @matches_as_team_a ||= team.matches_as_team_a.where(group_id: group.id)
  end

  def matches_as_team_b
    return Match.none unless team
    @matches_as_team_b ||= team.matches_as_team_b.where(group_id: group.id)
  end

  def calculate_points
    points_as_team_a = matches_as_team_a.sum(:point_a)
    points_as_team_b = matches_as_team_b.sum(:point_b)
    points_as_team_a + points_as_team_b
  end

  def calculate_score_difference
    score_difference_as_team_a = matches_as_team_a.sum(:score_a) - matches_as_team_a.sum(:score_b)
    score_difference_as_team_b = matches_as_team_b.sum(:score_b) - matches_as_team_b.sum(:score_a)
    score_difference_as_team_a + score_difference_as_team_b
  end

  def calculate_draws
    count(:draw)
  end

  def calculate_losses
    count(:lose)
  end

  def calculate_wins
    count(:win)
  end

  def count(situation)
    as_team_a = matches_as_team_a.where(point_a: Match::POINTS[situation]).count
    as_team_b = matches_as_team_b.where(point_b: Match::POINTS[situation]).count
    as_team_a + as_team_b
  end
end
