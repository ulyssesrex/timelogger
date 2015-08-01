class AddPasswordDigestToOrganizations < ActiveRecord::Migration
  def up
    add_column :organizations, :password_digest, :string
    remove_column :organizations, :keyword_digest
  end
  
  def down
    add_column :organization, :keyword_digest, :string
    remove_column :organizations, :password_digest
  end
end
