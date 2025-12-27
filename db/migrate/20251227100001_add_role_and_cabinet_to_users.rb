class AddRoleAndCabinetToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, default: 0, null: false
    add_reference :users, :cabinet, foreign_key: true
    
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :telephone, :string

    add_index :users, :role
  end
end
