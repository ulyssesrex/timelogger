class AddDefaultFalseValueToActivatedInUsers < ActiveRecord::Migration
  def up
    change_column :users, :activated, :boolean, default: false
  end
  
  def down
    change_column :users, :activated, :boolean, default: nil
  end
end
