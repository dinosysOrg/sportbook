ActiveAdmin.register Match do
  config.sort_order = 'groups.name'

  index do
    selectable_column
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :group, sortable: 'groups.name' do |record|
      link_to record.group.name, admin_group_path(record.group)
    end
    column :code
    column :team_a do |record|
      link_to record.team_a.name, admin_team_path(record.team_a)
    end
    column :team_b do |record|
      link_to record.team_b.name, admin_team_path(record.team_b)
    end
    column :score do |record|
      "#{record.score_a}-#{record.score_b}"
    end
    column :point do |record|
      "#{record.point_a}-#{record.point_b}"
    end
    column :time
    column :venue do |record|
      link_to record.venue.name, admin_venue_path(record.venue)
    end
    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:group)
    end
  end

  permit_params do
    [:name, :tournament_id]
  end
end