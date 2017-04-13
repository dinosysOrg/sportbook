ActiveAdmin.register Team do
  index do
    selectable_column
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :group do |record|
      link_to record.group.name, admin_group_path(record.group)
    end
    column :name
    actions
  end

  permit_params do
    [:name, :tournament_id]
  end
end
