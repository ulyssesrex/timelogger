class DeletePayPeriodInfoFromGrants < ActiveRecord::Migration
  def up
    remove_column :grants, :ppd_hours_percent, :float
    remove_column :grants, :ppd_hours,         :float
  end
  
  def down
    add_column :grants, :ppd_hours_percent, :float
    add_column :grants, :ppd_hours,         :float
  end
end
