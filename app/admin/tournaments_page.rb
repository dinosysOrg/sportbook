ActiveAdmin.register Tournament do
  filter :name, filters: [:contains]

  index do
    id_column
    column :name
    actions
  end

  permit_params do
    [:name, :start_date, :end_date]
  end
end
