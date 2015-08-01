class AddKeywordDigestToOrganizations < ActiveRecord::Migration
  def up
    add_column :organizations, :keyword_digest, :string
    remove_index  :organizations, :keyword
    remove_column :organizations, :keyword
  end
  
  def down
    add_column :organizations, :keyword, :string
    add_index  :organizations, :keyword
    remove_column :organizations, :keyword_digest, :string
  end
end
