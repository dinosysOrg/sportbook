ActiveAdmin.register Match do
  actions :index, :show, :edit, :update, :destroy

  filter :group_tournament_id, as: :select, collection: -> { Tournament.all }
  filter :team_a_name_or_team_b_name, as: :string, filters: [:contains]
  filter :venue

  config.sort_order = 'code_asc'

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
    column :calendar_link, sortable: false do |record|
      link_to fa_icon('calendar'), target: :_blank if record.calendar_link
    end
    actions do |record|
      item t('.add_to_calendar'), add_to_calendar_admin_match_path(record), method: :put, remote: true, class: 'member_link'
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

  member_action :add_to_calendar, method: :put do
    match = Match.find params[:id]
    result = GoogleCalendarService.instance.create_match_event(match)
    match.calendar_link = result.html_link
    match.save!

    redirect_to collection_url
  end

  action_item :add_to_calendar, only: :show do
    link_to t('.add_to_calendar'), add_to_calendar_admin_match_path(resource), method: :put, remote: true
  end
end
