ActiveAdmin.register Appointment do
  menu priority: 4

  permit_params :cabinet_id, :patient_id, :medecin_id, :date_rdv, :heure_debut, 
                :heure_fin, :duree, :motif, :notes, :statut, :raison_annulation

  index do
    selectable_column
    id_column
    column :cabinet
    column :patient do |appointment|
      link_to appointment.patient.nom_complet, admin_patient_path(appointment.patient) if appointment.patient
    end
    column :medecin do |appointment|
      "Dr #{appointment.medecin.last_name} #{appointment.medecin.first_name}" if appointment.medecin
    end
    column :date_rdv
    column :heure_debut do |appointment|
      appointment.heure_debut.strftime("%H:%M")
    end
    column :statut do |appointment|
      status_tag appointment.statut, class: Appointment::STATUT_COLORS[appointment.statut]
    end
    actions
  end

  filter :cabinet
  filter :patient
  filter :medecin, as: :select, collection: -> { User.where(role: [:medecin, :owner]) }
  filter :date_rdv
  filter :statut, as: :select, collection: Appointment.statuts.keys
  filter :created_at

  form do |f|
    f.inputs do
      f.input :cabinet
      f.input :patient, collection: Patient.order(:nom, :prenom)
      f.input :medecin, as: :select, collection: User.where(role: [:medecin, :owner]).map { |u| ["Dr #{u.last_name} #{u.first_name}", u.id] }
      f.input :date_rdv, as: :datepicker
      f.input :heure_debut, as: :time_picker
      f.input :heure_fin, as: :time_picker
      f.input :duree, hint: "Durée en minutes"
      f.input :motif
      f.input :notes
      f.input :statut, as: :select, collection: Appointment.statuts.keys
      f.input :raison_annulation, hint: "Uniquement si annulé"
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :cabinet
      row :patient do |appointment|
        link_to appointment.patient.nom_complet, admin_patient_path(appointment.patient) if appointment.patient
      end
      row :medecin do |appointment|
        "Dr #{appointment.medecin.last_name} #{appointment.medecin.first_name}" if appointment.medecin
      end
      row :date_rdv
      row :heure_debut do |appointment|
        appointment.heure_debut.strftime("%H:%M")
      end
      row :heure_fin do |appointment|
        appointment.heure_fin.strftime("%H:%M")
      end
      row :duree
      row :motif
      row :notes
      row :statut do |appointment|
        status_tag appointment.statut, class: Appointment::STATUT_COLORS[appointment.statut]
      end
      row :heure_arrivee
      row :heure_appel
      row :heure_debut_consultation
      row :heure_fin_consultation
      row :raison_annulation
      row :created_at
      row :updated_at
    end
  end
end
