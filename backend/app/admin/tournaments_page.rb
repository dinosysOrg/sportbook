ActiveAdmin.register Tournament do
  filter :name, filters: [:contains]

  index do
    selectable_column
    id_column
    column :name
    actions
  end

  permit_params do
    [:name]
  end
end
