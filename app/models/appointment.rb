class Appointment < ApplicationRecord
  include CabinetScoped

  # Relations
  belongs_to :patient
  belongs_to :medecin, class_name: 'User'
  has_one :consultation, dependent: :destroy

  # Enums - Statuts avec couleurs de l'image
  enum statut: {
    a_venir: 0,           # Rose - À venir
    en_salle_attente: 1,  # Jaune - En salle d'attente
    vu: 2,                # Vert - Vu
    encaisse: 3,          # Noir - Encaissé
    absent: 4,            # Bleu - Absent
    annule: 5             # Gris - Annulé
  }

  # Validations
  validates :date_rdv, :heure_debut, :medecin_id, :patient_id, presence: true
  validates :duree, numericality: { greater_than: 0 }
  validate :medecin_disponible, on: :create
  validate :pas_de_conflit_horaire

  # Callbacks
  before_save :calculer_heure_fin

  # Scopes
  scope :du_jour, -> { where(date_rdv: Date.today) }
  scope :a_venir, -> { where(statut: :a_venir) }
  scope :en_attente, -> { where(statut: :en_salle_attente).order(:heure_arrivee) }
  scope :de_la_semaine, ->(date) { 
    where(date_rdv: date.beginning_of_week..date.end_of_week) 
  }
  scope :par_medecin, ->(medecin_id) { where(medecin_id: medecin_id) }
  scope :par_date, ->(date) { where(date_rdv: date) }
  scope :order_by_time, -> { order(:heure_debut) }

  # Méthodes statut
  STATUT_COLORS = {
    'a_venir' => 'pink',
    'en_salle_attente' => 'warning',
    'vu' => 'success',
    'encaisse' => 'dark',
    'absent' => 'info',
    'annule' => 'secondary'
  }.freeze

  STATUT_LABELS = {
    'a_venir' => 'À venir',
    'en_salle_attente' => 'En salle d\'attente',
    'vu' => 'Vu',
    'encaisse' => 'Encaissé',
    'absent' => 'Absent',
    'annule' => 'Annulé'
  }.freeze

  def statut_color
    STATUT_COLORS[statut] || 'secondary'
  end

  def statut_label
    STATUT_LABELS[statut] || statut.humanize
  end

  # Gestion du flux
  def marquer_arrive!
    update(statut: :en_salle_attente, heure_arrivee: Time.current)
  end

  def appeler!
    update(heure_appel: Time.current)
  end

  def commencer_consultation!
    update(statut: :vu, heure_debut_consultation: Time.current)
  end

  def terminer_consultation!
    update(heure_fin_consultation: Time.current)
  end

  def marquer_encaisse!
    update(statut: :encaisse)
  end

  def marquer_absent!(raison = nil)
    update(statut: :absent, raison_annulation: raison)
  end

  def annuler!(raison = nil)
    update(statut: :annule, raison_annulation: raison)
  end

  # Horaires
  def heure_debut_formattee
    heure_debut&.strftime("%H:%M")
  end

  def heure_fin_formattee
    heure_fin&.strftime("%H:%M")
  end

  def temps_attente
    return nil unless heure_arrivee && heure_appel
    
    ((heure_appel - heure_arrivee) / 60).round # en minutes
  end

  def duree_consultation
    return nil unless heure_debut_consultation && heure_fin_consultation
    
    ((heure_fin_consultation - heure_debut_consultation) / 60).round # en minutes
  end

  # Couleur selon le statut pour le calendrier
  def statut_color
    case statut.to_sym
    when :a_venir
      '#f8bbd0'  # Rose - À venir
    when :en_salle_attente
      '#fff59d'  # Jaune - En salle d'attente
    when :vu
      '#a5d6a7'  # Vert - Vu
    when :encaisse
      '#424242'  # Noir - Encaissé
    when :absent
      '#90caf9'  # Bleu - Absent
    when :annule
      '#b0bec5'  # Gris - Annulé
    else
      '#9e9e9e'  # Gris par défaut
    end
  end

  private

  def calculer_heure_fin
    if heure_debut && duree
      time = Time.parse(heure_debut.to_s)
      self.heure_fin = (time + duree.minutes).to_time
    end
  end

  def medecin_disponible
    return unless medecin_id && date_rdv && heure_debut
    
    unless medecin&.medecin_or_owner?
      errors.add(:medecin_id, "doit être un médecin")
    end
  end

  def pas_de_conflit_horaire
    return unless date_rdv && heure_debut && heure_fin && medecin_id
    
    # Vérifier les chevauchements : deux RDV se chevauchent si
    # le début de l'un est avant la fin de l'autre ET vice versa
    conflits = Appointment.unscoped
      .where(medecin_id: medecin_id, date_rdv: date_rdv)
      .where.not(id: id)
      .where.not(statut: [:annule, :absent])
      .where("heure_debut < ? AND heure_fin > ?", heure_fin, heure_debut)
    
    if conflits.exists?
      conflit = conflits.first
      errors.add(:heure_debut, "conflit avec le RDV de #{conflit.patient.nom_complet} (#{conflit.heure_debut.strftime('%H:%M')} - #{conflit.heure_fin.strftime('%H:%M')})")
    end
  end
end
