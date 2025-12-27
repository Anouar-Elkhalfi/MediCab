class CreatePatients < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      # Informations de base
      t.string :numero_dossier
      t.string :civilite # M., Mme, Mlle
      t.string :nom, null: false
      t.string :prenom, null: false
      t.string :sexe # Homme, Femme, Autre
      t.string :telephone
      t.string :indicatif_pays, default: '+33'
      t.date :date_naissance
      t.string :profession
      t.text :adresse
      
      # Informations administratives
      t.string :cin # Carte Identité Nationale
      t.string :situation_familiale # Célibataire, Marié(e), Divorcé(e), Veuf(ve)
      t.string :lead_status # Nouveau, En cours, Converti, etc.
      t.string :mutuelle
      t.string :immatriculation # Numéro sécurité sociale
      t.text :commentaire
      t.string :provenance # Comment le patient a trouvé le cabinet
      t.string :ville
      
      # Relations
      t.references :cabinet, null: false, foreign_key: true
      t.references :user, foreign_key: true # Lien avec le compte utilisateur si le patient a un compte

      t.timestamps
    end

    add_index :patients, :numero_dossier
    add_index :patients, :nom
    add_index :patients, :cin
    add_index :patients, [:cabinet_id, :numero_dossier], unique: true
  end
end
