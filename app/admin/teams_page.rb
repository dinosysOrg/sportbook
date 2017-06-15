ActiveAdmin.register Team do
  actions :index, :show, :edit, :update, :destroy

  filter :tournament
  filter :name, filters: [:contains]

  index do
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :name
    column :status
    actions
  end

  show do
    attributes_table do
      row :tournament
      row :name
      row :status
      row :groups do |object|
        object.groups.pluck(:name).join(', ')
      end
    end
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :tournament, input_html: { disabled: true }
      f.input :name
      f.input :status
      if f.object.tournament
        f.has_many :groups_teams do |groups_team|
          groups_team.input :group, collection: f.object.tournament.groups
          groups_team.input :order
        end
      end
    end
    f.actions
  end

  permit_params :name, :tournament_id, :status, groups_teams_attributes: [:id, :group_id, :order, :_destroy]
end
