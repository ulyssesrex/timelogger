class ChangeTimeAllocationHoursColumnTypeToFloat < ActiveRecord::Migration
  def up
  	change_column :time_allocations, :hours, :float
  end

  def down
  	change_column :time_allocations, :hours, :string
  end
end
