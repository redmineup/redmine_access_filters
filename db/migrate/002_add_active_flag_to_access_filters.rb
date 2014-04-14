class AddActiveFlagToAccessFilters < ActiveRecord::Migration
  def change
    add_column :access_filters, :active, :boolean, :default => true
  end
end