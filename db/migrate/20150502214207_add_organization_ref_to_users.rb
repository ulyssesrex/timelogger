class AddOrganizationRefToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :organization, index: true
    add_foreign_key :users, :organizations
  end
end
