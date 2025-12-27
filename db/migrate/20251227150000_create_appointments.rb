class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      # Relations
      t.references :cabinet, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.references :medecin, null: false, foreign_key: { to_table: :users }
      
      # Date et heure
      t.date :date_rdv, null: false
      t.time :heure_debut, null: false
      t.time :heure_fin
      t.integer :duree, default: 30 # en minutes
      
      # Informations
      t.string :motif
      t.text :notes
      
      # Statut avec couleurs de l'image
      # 0: à_venir (rose), 1: en_salle_attente (jaune), 2: vu (vert)
      # 3: encaisse (noir), 4: absent (bleu), 5: annule (gris)
      t.integer :statut, default: 0, null: false
      
      # Métadonnées
      t.datetime :heure_arrivee # Quand le patient arrive
      t.datetime :heure_appel # Quand on appelle le patient
      t.datetime :heure_debut_consultation # Début consultation
      t.datetime :heure_fin_consultation # Fin consultation
      t.text :raison_annulation

      t.timestamps
    end

    add_index :appointments, :date_rdv
    add_index :appointments, :statut
    add_index :appointments, [:cabinet_id, :date_rdv]
    add_index :appointments, [:medecin_id, :date_rdv]
  end
end
