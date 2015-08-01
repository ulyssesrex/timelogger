class ChangeLeaveColumnsInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :pay_period_length_in_days, :pay_periods_per_month
    rename_column :users, :al_taken, :al_at_start
    rename_column :users, :sl_taken, :sl_at_start
    rename_column :users, :ol_taken, :ol_at_start
  end
end
