class DeleteLeaveInfoFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :pay_periods_per_month, :integer
    remove_column :users, :hours_per_week,        :integer
    remove_column :users, :al_rate,               :float
    remove_column :users, :ol_rate,               :float
    remove_column :users, :sl_rate,               :float
    remove_column :users, :al_at_start,           :float
    remove_column :users, :sl_at_start,           :float
    remove_column :users, :ol_at_start,           :float
  end
  
  def down
    add_column :users, :pay_periods_per_month, :integer
    add_column :users, :hours_per_week,        :integer
    add_column :users, :al_rate,               :float
    add_column :users, :ol_rate,               :float
    add_column :users, :sl_rate,               :float
    add_column :users, :al_at_start,           :float
    add_column :users, :sl_at_start,           :float
    add_column :users, :ol_at_start,           :float
  end
end
