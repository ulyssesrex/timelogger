class CreateTimesheets < ActiveRecord::Migration
  def change
    create_table :timesheets do |t|
      t.references :user, index: true
      t.text :comments
      t.time :start_time
      t.time :end_time

      t.timestamps null: false
    end
    add_foreign_key :timesheets, :users
  end
end
