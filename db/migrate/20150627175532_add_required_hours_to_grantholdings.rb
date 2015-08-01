class AddRequiredHoursToGrantholdings < ActiveRecord::Migration
  def change
    add_column :grantholdings, :required_hours, :float
  end
end
