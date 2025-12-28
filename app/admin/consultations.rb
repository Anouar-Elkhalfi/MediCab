ActiveAdmin.register Consultation do
  menu priority: 5

  # Configuration
  config.batch_actions = true

  # Scopes
  scope :all, default: true
  scope :recentes, -> { recentes }

  # Filtres
  filter :appointment_patient_nom_or_appointment_patient_prenom_cont, label: 'Patient (Nom/Prénom)'
  filter :appointment_medecin_first_name_or_appointment_medecin_last_name_cont, label: 'Médecin'
  filter :appointment_cabinet, label: 'Cabinet', as: :select, collection: -> { Cabinet.all }
  filter :diagnostic_cont, label: 'Diagnostic'
  filter :motif_cont, label: 'Motif'
  filter :created_at, label: 'Date de création'

  # Index
  index do
    selectable_column
    id_column
    
    column 'Date', :date_consultation do |consultation|
      consultation.date_consultation.strftime('%d/%m/%Y')
    end
    
    column 'Patient' do |consultation|
      link_to consultation.patient.nom_complet, admin_patient_path(consultation.patient)
    end
    
    column 'Cabinet' do |consultation|
      consultation.cabinet.nom
    end
    
    column 'Médecin' do |consultation|
      consultation.medecin.full_name
    end
    
    column 'Motif' do |consultation|
      truncate(consultation.motif, length: 50)
    end
    
    column 'Diagnostic' do |consultation|
      truncate(consultation.diagnostic, length: 50)
    end
    
    column 'Créée le', :created_at do |consultation|
      l consultation.created_at, format: :short
    end
    
    actions
  end

  # Show
  show do
    attributes_table do
      row :id
      row 'Date consultation' do |consultation|
        l consultation.date_consultation, format: :long
      end
      row 'Patient' do |consultation|
        link_to consultation.patient.nom_complet, admin_patient_path(consultation.patient)
      end
      row 'N° Dossier' do |consultation|
        consultation.patient.numero_dossier
      end
      row 'Cabinet' do |consultation|
        link_to consultation.cabinet.nom, admin_cabinet_path(consultation.cabinet)
      end
      row 'Médecin' do |consultation|
        consultation.medecin.full_name
      end
    end

    panel 'Informations Générales' do
      attributes_table_for consultation do
        row 'Motif' do |c|
          simple_format(c.motif)
        end
        row 'Antécédents' do |c|
          simple_format(c.antecedents) if c.antecedents.present?
        end
      end
    end

    panel 'Examen et Diagnostic' do
      attributes_table_for consultation do
        row 'Examen clinique' do |c|
          simple_format(c.examen_clinique) if c.examen_clinique.present?
        end
        row 'Examens complémentaires' do |c|
          simple_format(c.examens_complementaires) if c.examens_complementaires.present?
        end
        row 'Diagnostic' do |c|
          simple_format(c.diagnostic)
        end
        row 'Conclusion' do |c|
          simple_format(c.conclusion) if c.conclusion.present?
        end
      end
    end

    panel 'Traitement et Suivi' do
      attributes_table_for consultation do
        row 'Traitement prescrit' do |c|
          simple_format(c.traitement) if c.traitement.present?
        end
        row 'Ordonnance' do |c|
          simple_format(c.ordonnance) if c.ordonnance.present?
        end
        row 'Observations' do |c|
          simple_format(c.observations) if c.observations.present?
        end
        row 'Notes internes' do |c|
          simple_format(c.notes_internes) if c.notes_internes.present?
        end
        row 'Prochain RDV' do |c|
          l c.prochain_rdv, format: :long if c.prochain_rdv.present?
        end
      end
    end

    panel 'Métadonnées' do
      attributes_table_for consultation do
        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  # Form
  form do |f|
    f.semantic_errors

    f.inputs 'Rendez-vous' do
      f.input :appointment, as: :select, collection: Appointment.includes(:patient, :medecin, :cabinet).order('date_rdv DESC').map { |a| 
        ["#{a.date_rdv.strftime('%d/%m/%Y')} - #{a.patient.nom_complet} - Dr #{a.medecin.full_name}", a.id] 
      }
    end

    f.inputs 'Informations Générales' do
      f.input :motif, as: :text, input_html: { rows: 3 }
      f.input :antecedents, as: :text, input_html: { rows: 3 }
    end

    f.inputs 'Examen et Diagnostic' do
      f.input :examen_clinique, as: :text, input_html: { rows: 5 }
      f.input :examens_complementaires, as: :text, input_html: { rows: 3 }
      f.input :diagnostic, as: :text, input_html: { rows: 5 }
      f.input :conclusion, as: :text, input_html: { rows: 3 }
    end

    f.inputs 'Traitement et Suivi' do
      f.input :traitement, as: :text, input_html: { rows: 5 }
      f.input :ordonnance, as: :text, input_html: { rows: 5 }
      f.input :observations, as: :text, input_html: { rows: 5 }
      f.input :notes_internes, as: :text, input_html: { rows: 3 }
      f.input :prochain_rdv, as: :datepicker
    end

    f.actions
  end

  # Permitted parameters
  permit_params :appointment_id, :motif, :antecedents, :examen_clinique, 
                :examens_complementaires, :diagnostic, :conclusion, 
                :traitement, :ordonnance, :observations, :notes_internes, 
                :prochain_rdv
end
