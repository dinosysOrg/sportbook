class GroupsDecorator < Draper::CollectionDecorator
  def as_pairs
    group_pairs.map do |group_pair|
      group_a = group_pair[0]
      group_b = group_pair[1]

      teams_a = group_a.groups_teams
      teams_b = group_b.groups_teams

      max_teams_count = teams_a.size > teams_b.size ? teams_a.size : teams_b.size
      team_pairs = Array.new(max_teams_count) do |i|
        [teams_a[i], teams_b[i]]
      end

      OpenStruct.new(group_a: group_a.name, group_b: group_b.name, team_pairs: team_pairs)
    end
  end

  private

  def group_pairs
    return [] if object.empty?

    half_size = (object.size / 2.0).ceil
    left, right = object.each_slice(half_size).to_a
    left.zip(right)
  end
end
