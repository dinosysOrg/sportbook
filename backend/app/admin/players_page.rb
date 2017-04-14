ActiveAdmin.register Player do
  index do
    selectable_column
    column :id
    column :tournament do |record|
      link_to record.tournament.name, admin_tournament_path(record.tournament)
    end
    column :team do |record|
      if record.team
        link_to record.team.name, admin_user_path(record.team)
      else
        nil
      end
    end
    column :user do |record|
      link_to record.user.name, admin_user_path(record.user)
    end
    column :phone_number do |record|
      record.user.phone_number
    end
    actions
  end

  permit_params do
    [:user_id, :tournament_id]
  end
end
