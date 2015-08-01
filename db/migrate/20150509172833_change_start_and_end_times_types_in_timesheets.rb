class ChangeStartAndEndTimesTypesInTimesheets < ActiveRecord::Migration
  def up
    change_column :timesheets, :start_time, :datetime
    change_column :timesheets, :end_time, :datetime
  end
  def down
    change_column :timesheets, :start_time, :time
    change_column :timesheets, :end_time, :time
  end
end
