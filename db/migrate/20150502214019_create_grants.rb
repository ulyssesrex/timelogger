class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.string :name
      t.text :comments
      t.float :ppd_hours_percent
      t.float :ppd_hours
      t.references :organization, index: true

      t.timestamps null: false
    end
    add_foreign_key :grants, :organizations
  end
end
