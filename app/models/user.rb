class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  belongs_to :cabinet, optional: true
  has_many :appointments, foreign_key: :medecin_id, dependent: :destroy

  # Enums
  enum role: {
    patient: 0,
    secretaire: 1,
    medecin: 2,
    owner: 3,
    super_admin: 4
  }

  # Validations
  validates :role, presence: true

  # Scopes
  scope :of_cabinet, ->(cabinet_id) { where(cabinet_id: cabinet_id) }

  # Methods
  def full_name
    "#{first_name} #{last_name}".strip.presence || email
  end

  def can_manage_cabinet?
    owner? || super_admin?
  end

  def medecin_or_owner?
    medecin? || owner?
  end

  def secretaire_or_above?
    secretaire? || medecin? || owner? || super_admin?
  end
end
