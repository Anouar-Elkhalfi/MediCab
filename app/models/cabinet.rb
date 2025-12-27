class Cabinet < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :medecins, -> { where(role: :medecin) }, class_name: 'User'
  has_many :secretaires, -> { where(role: :secretaire) }, class_name: 'User'
  has_many :user_patients, -> { where(role: :patient) }, class_name: 'User'
  has_many :patients, dependent: :destroy
  has_many :appointments, dependent: :destroy

  validates :nom, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :siret, uniqueness: true, allow_blank: true
end
