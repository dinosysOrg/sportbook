ActiveAdmin.register Group do
  index do
    selectable_column
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :name
    actions
  end

  permit_params do
    [:name, :tournament_id]
  end
end
