class CreateCabinets < ActiveRecord::Migration[7.1]
  def change
    create_table :cabinets do |t|
      t.string :nom, null: false
      t.text :adresse
      t.string :telephone
      t.string :email
      t.string :siret
      t.string :specialite

      t.timestamps
    end

    add_index :cabinets, :siret, unique: true
  end
end
