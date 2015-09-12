class AddResetDigestAndResetSentAtToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :reset_digest, :string
    add_column :organizations, :reset_sent_at, :datetime
  end
end
