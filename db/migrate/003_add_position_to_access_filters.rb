class AddPositionToAccessFilters < ActiveRecord::Migration[5.2]
  def change
    add_column :access_filters, :position, :integer, :default => 0
  end
end
