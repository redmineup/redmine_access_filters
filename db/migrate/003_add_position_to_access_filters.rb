class AddPositionToAccessFilters < ActiveRecord::Migration
  def change
    add_column :access_filters, :position, :integer, :default => 0
  end
end