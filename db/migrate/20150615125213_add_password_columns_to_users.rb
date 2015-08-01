class AddPasswordColumnsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :reset_digest, :string
    add_column :users, :reset_sent_at, :datetime
    remove_column :users, :password
  end
  
  def down
    add_column :users, :password, :string
    remove_column :users, :reset_sent_at
    remove_column :users, :reset_digest
  end
end
