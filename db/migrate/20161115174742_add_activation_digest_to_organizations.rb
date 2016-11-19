class AddActivationDigestToOrganizations < ActiveRecord::Migration
  def change
  	add_column :organizations, :activation_digest, :string
  end
end
