class AddIndexToOrganizationKeyword < ActiveRecord::Migration
  def change
    add_index :organizations, :keyword
  end
end
