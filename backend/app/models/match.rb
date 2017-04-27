class Match < ApplicationRecord
  POINTS = {
    win: 3,
    lose: 0,
    draw: 1
  }.freeze

  belongs_to :group
  belongs_to :venue
  belongs_to :team_a, class_name: 'Team'
  belongs_to :team_b, class_name: 'Team'

  validates :group, presence: true

  after_save :recalculate_groups_teams_statistics
  after_destroy :recalculate_groups_teams_statistics

  delegate :tournament, to: :group

  def score
    "#{score_a}-#{score_b}"
  end

  def score=(match_score)
    score_a, score_b = match_score.split('-')
    self.score_a = score_a
    self.score_b = score_b
    calculate_points_from_score
  end

  def point
    "#{point_a}-#{point_b}"
  end

  def point=(point)
    point_a, point_b = point.split('-')
    self.point_a = point_a
    self.point_b = point_b
  end

  def groups_teams
    @groups_teams ||= group.groups_teams.where(team_id: [team_a_id, team_b_id])
  end

  def team_a_wins
    self.point = "#{POINTS[:win]}-#{POINTS[:lose]}"
  end

  def team_b_wins
    self.point = "#{POINTS[:lose]}-#{POINTS[:win]}"
  end

  def draws
    self.point = "#{POINTS[:draw]}-#{POINTS[:draw]}"
  end

  def both_lose
    self.point = "#{POINTS[:lose]}-#{POINTS[:lose]}"
  end

  private

  def calculate_points_from_score
    return self.point = '0-0' unless score_a && score_b
    case (score_a <=> score_b)
    when 1
      team_a_wins
    when -1
      team_b_wins
    when 0
      draws
    else
      both_lose
    end
  end

  def recalculate_groups_teams_statistics
    groups_teams.each(&:recalculate_statistics)
  end
end
