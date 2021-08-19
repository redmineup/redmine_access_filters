class AddActiveFlagToAccessFilters < ActiveRecord::Migration[5.2]
  def change
    add_column :access_filters, :active, :boolean, :default => true
  end
end
