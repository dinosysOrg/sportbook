ActiveAdmin.register Venue do
  filter :name, filter: [:contains]

  index do
    id_column
    column :name
    actions
  end

  permit_params do
    [:name]
  end
end
