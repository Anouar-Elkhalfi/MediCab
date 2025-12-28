class AddFieldsToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :motif, :text
    add_column :consultations, :antecedents, :text
    add_column :consultations, :examen_clinique, :text
    add_column :consultations, :conclusion, :text
    add_column :consultations, :examens_complementaires, :text
    add_column :consultations, :notes_internes, :text
  end
end
