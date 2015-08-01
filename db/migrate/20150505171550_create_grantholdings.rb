class CreateGrantholdings < ActiveRecord::Migration
  def change
    create_table :grantholdings do |t|
      t.references :grant, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :grantholdings, :grants
    add_foreign_key :grantholdings, :users
  end
end
