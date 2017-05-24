ActiveAdmin.register User do
  permit_params :name, :email, :phone_number, :password, :password_confirmation, role_ids: []

  index do
    id_column
    column :name
    column :slug
    column :phone_number
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :nickname
      row :image
      row :email
      row :phone_number
      row :skill
      row :address
      row :note
      row :slug
      row :facebook_uid
      row :created_at
      row :updated_at
    end
  end

  filter :name
  filter :phone_number

  form do |f|
    f.inputs 'Admin Details' do
      f.input :name
      f.input :phone_number
      f.input :email
      f.input :roles, as: :check_boxes, input_html: { style: 'width: auto; margin-right: 10px;' }
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
