class AddActivationDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activation_digest, :string
  end
end
