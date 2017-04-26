class Match < ApplicationRecord
  POINTS = {
    win: 3,
    lose: 0,
    draw: 0
  }.freeze

  belongs_to :group
  belongs_to :venue
  belongs_to :team_a, class_name: 'Team'
  belongs_to :team_b, class_name: 'Team'

  validates :group, presence: true

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

  private

  def calculate_points_from_score
    return self.point = '0-0' unless score_a && score_b
    self.point = case (score_a <=> score_b)
                 when 1
                   "#{POINTS[:win]}-#{POINTS[:lose]}"
                 when -1
                   "#{POINTS[:lose]}-#{POINTS[:win]}"
                 when 0
                   "#{POINTS[:draw]}-#{POINTS[:draw]}"
                 else
                   "#{POINTS[:lose]}-#{POINTS[:lose]}"
                 end
  end
end
