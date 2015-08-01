class CreateSupervisions < ActiveRecord::Migration
  def change
    create_table :supervisions do |t|
      t.timestamps null: false
    end
    add_reference :supervisions, :supervisor, references: :users, index: true
    add_reference :supervisions, :supervisee, references: :users, index: true
    
    add_foreign_key :supervisions, :users, column: :supervisor_id
    add_foreign_key :supervisions, :users, column: :supervisee_id
  end
end
