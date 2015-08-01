class ChangeColumnsInTimeAllocationsToStartAndEnd < ActiveRecord::Migration
  def change
    rename_column :time_allocations, :date, :start
    remove_column :time_allocations, :hours
    add_column    :time_allocations, :end, :datetime
  end
end
