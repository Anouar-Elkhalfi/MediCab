ActiveAdmin.register Patient do
  menu priority: 3

  permit_params :numero_dossier, :civilite, :nom, :prenom, :sexe, 
                :telephone, :indicatif_pays, :date_naissance, :profession, :adresse,
                :cin, :situation_familiale, :lead_status, :mutuelle, 
                :immatriculation, :commentaire, :provenance, :ville, :cabinet_id

  index do
    selectable_column
    id_column
    column :numero_dossier
    column "Nom complet" do |patient|
      patient.nom_complet
    end
    column :telephone
    column :date_naissance
    column "Âge" do |patient|
      patient.age ? "#{patient.age} ans" : "-"
    end
    column :ville
    column :mutuelle
    column :cabinet
    column :created_at
    actions
  end

  filter :numero_dossier
  filter :nom
  filter :prenom
  filter :civilite, as: :select, collection: Patient::CIVILITES
  filter :sexe, as: :select, collection: Patient::SEXES
  filter :telephone
  filter :ville
  filter :mutuelle
  filter :situation_familiale, as: :select, collection: Patient::SITUATIONS_FAMILIALES
  filter :lead_status, as: :select, collection: Patient::LEAD_STATUS
  filter :cabinet
  filter :created_at

  form do |f|
    f.inputs "Informations personnelles" do
      f.input :cabinet, as: :select, collection: Cabinet.all.map { |c| [c.nom, c.id] }
      f.input :numero_dossier, hint: "Laissez vide pour auto-génération"
      f.input :civilite, as: :select, collection: Patient::CIVILITES
      f.input :nom
      f.input :prenom
      f.input :sexe, as: :select, collection: Patient::SEXES
      f.input :date_naissance, as: :datepicker
      f.input :profession
      f.input :cin, label: "CIN"
    end

    f.inputs "Contact" do
      f.input :indicatif_pays
      f.input :telephone
      f.input :adresse, as: :text
      f.input :ville
      f.input :provenance, as: :select, collection: Patient::PROVENANCES
    end

    f.inputs "Informations médicales et administratives" do
      f.input :situation_familiale, as: :select, collection: Patient::SITUATIONS_FAMILIALES
      f.input :mutuelle
      f.input :immatriculation, label: "Immatriculation (N° sécu)"
      f.input :lead_status, as: :select, collection: Patient::LEAD_STATUS
      f.input :commentaire, as: :text
    end

    f.actions
  end

  show do
    attributes_table do
      row :numero_dossier
      row :cabinet
      row :civilite
      row :nom
      row :prenom
      row "Nom complet" do |patient|
        patient.nom_complet
      end
      row :sexe
      row :date_naissance
      row "Âge" do |patient|
        patient.age ? "#{patient.age} ans" : "-"
      end
      row :cin
      row :profession
      row :telephone
      row "Téléphone complet" do |patient|
        patient.telephone_complet
      end
      row :adresse
      row :ville
      row :provenance
      row :situation_familiale
      row :mutuelle
      row :immatriculation
      row :lead_status
      row :commentaire
      row :created_at
      row :updated_at
    end
  end
end
