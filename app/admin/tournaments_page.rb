ActiveAdmin.register Tournament do
  filter :name, filters: [:contains]

  index do
    id_column
    column :name
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :start_date, as: :date_picker
      f.input :end_date, as: :date_picker
    end
    f.actions
  end

  permit_params do
    [:name, :start_date, :end_date]
  end
end
