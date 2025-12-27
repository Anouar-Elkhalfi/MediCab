class CreateConsultations < ActiveRecord::Migration[7.1]
  def change
    create_table :consultations do |t|
      t.references :appointment, null: false, foreign_key: true
      t.text :diagnostic
      t.text :traitement
      t.text :observations
      t.text :ordonnance
      t.date :prochain_rdv

      t.timestamps
    end
  end
end
