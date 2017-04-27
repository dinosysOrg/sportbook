ActiveAdmin.register Venue do
  filter :name, filter: [:contains]

  index do
    id_column
    column :name
    column :calendar_id
    actions
  end

  permit_params do
    [:name, :calendar_id]
  end

  form do |f|
    f.inputs 'Venue Details' do
      f.input :name
      f.input :calendar_id
    end
    f.actions
  end
end
