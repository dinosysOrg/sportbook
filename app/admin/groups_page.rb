ActiveAdmin.register Group do
  actions :index, :show, :edit, :update, :destroy

  filter :tournament
  filter :name, filters: [:contains]

  index do
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :name
    actions
  end

  show do
    attributes_table do
      row :tournament
      row :name
      row :start_date
      row :teams do |object|
        object.teams.pluck(:name).join(', ')
      end
    end
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :tournament, input_html: { disabled: true }
      f.input :name
      f.input :start_date, as: :date_picker

      if f.object.tournament
        f.has_many :groups_teams do |groups_team|
          groups_team.input :team, collection: f.object.tournament.teams
          groups_team.input :order
        end
      end
    end
    f.actions
  end

  permit_params :name, :tournament_id, :start_date, groups_teams_attributes: [:id, :team_id, :order, :_destroy]
end
