class ConsolidateStartAndEndTimesInTimeAllocationsToHours < ActiveRecord::Migration
  def up
  	remove_column :time_allocations, :start_time
  	remove_column :time_allocations, :end_time
  	add_column    :time_allocations, :hours, :string
  end

  def down
  	remove_column :time_allocations, :hours
  	add_column :time_allocations, :start_time, :datetime
  	add_column :time_allocations, :end_time, :datetime
  end
end
