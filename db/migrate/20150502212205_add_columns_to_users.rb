class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_name, :string
    add_column :users, :position, :string
    add_column :users, :admin, :boolean
    add_column :users, :pay_period_length_in_days, :integer
    add_column :users, :hours_per_week, :float
    add_column :users, :start_date, :datetime
    add_column :users, :al_rate, :float
    add_column :users, :sl_rate, :float
    add_column :users, :ol_rate, :float
    add_column :users, :al_taken, :float
    add_column :users, :sl_taken, :float
    add_column :users, :ol_taken, :float
  end
end
