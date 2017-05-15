ActiveAdmin.register Page do
  # actions :index, :edit, :update, :show, :destroy
  filter :tournament

  index do
    id_column
    column :tournament do |record|
      record.tournament.try(:name)
    end
    column :name
    column :locale
    actions
  end

  form do |f|
    f.inputs 'Admin Details' do
      f.input :tournament
      f.input :name
      f.input :locale, as: :select, collection: [:vi, :en]
      f.input :html_content
    end
    f.actions
  end

  permit_params do
    [:name, :locale, :html_content, :tournament_id]
  end
end
