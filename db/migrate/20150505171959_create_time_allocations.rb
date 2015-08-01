class CreateTimeAllocations < ActiveRecord::Migration
  def change
    create_table :time_allocations do |t|
      t.references :grantholding, index: true
      t.references :timesheet, index: true
      t.float :hours
      t.datetime :date
      t.text :comments

      t.timestamps null: false
    end
    add_foreign_key :time_allocations, :grantholdings
    add_foreign_key :time_allocations, :timesheets
  end
end
