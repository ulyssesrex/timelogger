class RenameEndInTimeAllocations < ActiveRecord::Migration
  def change
    rename_column :time_allocations, :end, :end_time
    rename_column :time_allocations, :start, :start_time
  end
end
