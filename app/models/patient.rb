class Patient < ApplicationRecord
  include CabinetScoped

  # Relations
  belongs_to :user, optional: true
  has_many :appointments, dependent: :destroy

  # Validations
  validates :nom, :prenom, presence: true
  validates :numero_dossier, uniqueness: { scope: :cabinet_id }, allow_blank: true
  validates :telephone, presence: true
  
  # Callbacks
  before_validation :generate_numero_dossier, on: :create

  # Scopes
  scope :search, ->(query) {
    where("nom ILIKE ? OR prenom ILIKE ? OR telephone ILIKE ? OR numero_dossier ILIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
  }
  scope :by_civilite, ->(civilite) { where(civilite: civilite) if civilite.present? }
  scope :by_sexe, ->(sexe) { where(sexe: sexe) if sexe.present? }
  scope :by_situation_familiale, ->(situation) { where(situation_familiale: situation) if situation.present? }

  # Constants
  CIVILITES = ['M.', 'Mme', 'Mlle'].freeze
  SEXES = ['Homme', 'Femme', 'Autre'].freeze
  SITUATIONS_FAMILIALES = ['Célibataire', 'Marié(e)', 'Divorcé(e)', 'Veuf(ve)', 'Autre'].freeze
  LEAD_STATUS = ['Nouveau', 'En cours', 'Actif', 'Inactif'].freeze
  PROVENANCES = ['Bouche à oreille', 'Internet', 'Médecin traitant', 'Urgences', 'Autre'].freeze

  # Methods
  def full_name
    "#{prenom} #{nom}"
  end

  def nom_complet
    "#{civilite} #{full_name}"
  end

  def age
    return nil unless date_naissance
    
    today = Date.today
    age = today.year - date_naissance.year
    age -= 1 if today < date_naissance + age.years
    age
  end

  def telephone_complet
    "#{indicatif_pays} #{telephone}"
  end

  private

  def generate_numero_dossier
    return if numero_dossier.present?
    
    # Générer un numéro unique: année + séquence
    year = Date.today.year
    last_patient = cabinet.patients.unscoped.where("numero_dossier LIKE ?", "#{year}%").order(numero_dossier: :desc).first
    
    if last_patient && last_patient.numero_dossier
      sequence = last_patient.numero_dossier.split('-').last.to_i + 1
    else
      sequence = 1
    end
    
    self.numero_dossier = "#{year}-#{sequence.to_s.rjust(5, '0')}"
  end
end
