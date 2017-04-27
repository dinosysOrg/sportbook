ActiveAdmin.register Venue do
  filter :name, filter: [:contains]

  index do
    id_column
    column :name
    column :google_calendar_name
    actions
  end

  permit_params do
    [:name, :google_calendar_name]
  end

  form do |f|
    f.inputs 'Venue Details' do
      f.input :name
      f.input :google_calendar_name
    end
    f.actions
  end
end
