class Consultation < ApplicationRecord
  belongs_to :appointment

  # Validations
  validates :diagnostic, presence: true
  # Motif requis uniquement pour les nouvelles consultations

  # Délégations pour faciliter l'accès
  delegate :patient, :medecin, :cabinet, :date_rdv, to: :appointment

  # Scopes
  scope :recentes, -> { joins(:appointment).order('appointments.date_rdv DESC, appointments.heure_debut DESC') }
  scope :par_patient, ->(patient_id) { joins(:appointment).where(appointments: { patient_id: patient_id }) }

  # Méthodes
  def complet?
    diagnostic.present? && (traitement.present? || observations.present?)
  end

  def date_consultation
    appointment.date_rdv
  end

  def nom_medecin
    medecin.full_name
  end

  def titre_court
    "#{date_consultation.strftime('%d/%m/%Y')} - #{motif&.truncate(50) || 'Consultation'}"
  end
end
