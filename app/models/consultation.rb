class Consultation < ApplicationRecord
  belongs_to :appointment

  # Validations
  validates :diagnostic, presence: true

  # Délégations pour faciliter l'accès
  delegate :patient, :medecin, :cabinet, to: :appointment

  # Méthodes
  def complet?
    diagnostic.present? && (traitement.present? || observations.present?)
  end
end
