ActiveAdmin.register Venue do
  filter :name, filter: [:contains]

  index do
    id_column
    column :name
    column :google_calendar_name
    column :lat
    column :long
    actions
  end

  permit_params do
    [:name, :google_calendar_name, :lat, :long]
  end

  form do |f|
    f.inputs 'Venue Details' do
      f.input :name
      f.input :google_calendar_name
      f.input :lat
      f.input :long
    end
    f.actions
  end
end
