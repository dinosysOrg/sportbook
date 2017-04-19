ActiveAdmin.register User do
  permit_params :name, :email, :phone_number, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column :phone_number
    actions
  end

  filter :name
  filter :phone_number

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
      f.input :phone_number
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
