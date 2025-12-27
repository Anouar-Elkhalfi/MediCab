ActiveAdmin.register Cabinet do
  menu priority: 1

  permit_params :nom, :adresse, :telephone, :email, :siret, :specialite

  index do
    selectable_column
    id_column
    column :nom
    column :specialite
    column :telephone
    column :email
    column :siret
    column "Médecins" do |cabinet|
      cabinet.medecins.count
    end
    column "Patients" do |cabinet|
      cabinet.patients.count
    end
    column :created_at
    actions
  end

  filter :nom
  filter :specialite
  filter :email
  filter :created_at

  form do |f|
    f.inputs do
      f.input :nom
      f.input :specialite, as: :select, collection: ['Médecine générale', 'Cardiologie', 'Dermatologie', 'Pédiatrie', 'Autre']
      f.input :adresse, input_html: { rows: 3 }
      f.input :telephone
      f.input :email
      f.input :siret
    end
    f.actions
  end

  show do
    attributes_table do
      row :nom
      row :specialite
      row :adresse
      row :telephone
      row :email
      row :siret
      row :created_at
      row :updated_at
    end

    panel "Médecins" do
      table_for cabinet.medecins do
        column :email
        column :full_name
        column :telephone
        column :role
      end
    end

    panel "Secrétaires" do
      table_for cabinet.secretaires do
        column :email
        column :full_name
        column :telephone
      end
    end

    panel "Patients" do
      table_for cabinet.patients.limit(20) do
        column :email
        column :full_name
        column :telephone
      end
      div do
        "Total: #{cabinet.patients.count} patients"
      end
    end
  end
end
