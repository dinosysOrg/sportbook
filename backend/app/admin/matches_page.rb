ActiveAdmin.register Match do
  actions :index, :show, :edit, :update, :destroy

  filter :group_tournament_id, as: :select, collection: -> { Tournament.all }
  filter :team_a_name_or_team_b_name, as: :string, filters: [:contains]
  filter :venue

  config.sort_order = 'groups.name'

  index do
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
    column :calendar_link do |record|
      link_to truncate(record.calendar_link), record.calendar_link, target: :_blank if record.calendar_link
    end
    actions do |record|
      item "Add to Calendar", add_to_calendar_admin_match_path(record), method: :put, remote: true
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:group)
    end
  end

  permit_params do
    [:name, :tournament_id]
  end

  member_action :add_to_calendar, :method => :put do
    match = Match.find params[:id]
    result = GoogleCalendarService.instance.create_match_event(match)
    match.calendar_link = result.html_link
    match.save!

    redirect_to collection_url
  end

  action_item :add_to_calendar, only: :show do |match|
    link_to 'Add to calendar', add_to_calendar_admin_match_path(match), method: :put, remote: true
  end
end
