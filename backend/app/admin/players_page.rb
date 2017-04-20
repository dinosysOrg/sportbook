ActiveAdmin.register Player do
  actions :index, :show, :destroy

  filter :tournament
  filter :user

  index do
    selectable_column
    column :id
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :user do |record|
      link_to record.user.name, admin_user_path(record.user)
    end
    column :phone_number do |record|
      record.user.phone_number
    end
    actions
  end

  show do
    attributes_table do
      row :tournament
      row :user
    end
  end

  permit_params do
    [:user_id, :tournament_id]
  end
end
