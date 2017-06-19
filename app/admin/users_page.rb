ActiveAdmin.register User do
  permit_params :name, :email, :phone_number, :password, :password_confirmation, :address, :club, :birthday, role_ids: []

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
      row :club
      row :birthday
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
      f.input :birthday, as: :date_picker, datepicker_options: { dateFormat: 'dd/mm/yy' }
      f.input :club
      f.input :email
      f.input :address
      f.input :roles, as: :check_boxes, input_html: { style: 'width: auto; margin-right: 10px;' }
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete('password')
        params[:user].delete('password_confirmation')
      end
      super
    end
  end
end
