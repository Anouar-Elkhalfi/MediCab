ActiveAdmin.register User do
  menu priority: 2

  permit_params :email, :password, :password_confirmation, :first_name, :last_name, 
                :telephone, :role, :cabinet_id

  index do
    selectable_column
    id_column
    column :email
    column :full_name
    column :role do |user|
      status_tag user.role
    end
    column :cabinet
    column :telephone
    column :created_at
    actions
  end

  filter :email
  filter :first_name
  filter :last_name
  filter :role, as: :select, collection: User.roles
  filter :cabinet
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :telephone
      f.input :role, as: :select, collection: User.roles.keys
      f.input :cabinet, as: :select, collection: Cabinet.all.map { |c| [c.nom, c.id] }
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :first_name
      row :last_name
      row :full_name
      row :telephone
      row :role do |user|
        status_tag user.role
      end
      row :cabinet
      row :created_at
      row :updated_at
    end
  end
end
