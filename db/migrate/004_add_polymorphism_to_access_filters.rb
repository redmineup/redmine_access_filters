class AddPolymorphismToAccessFilters < ActiveRecord::Migration
  def change
    add_column :access_filters, :owner_type, :string
    add_column :access_filters, :owner_id, :integer
    remove_column :access_filters, :user_id
  end
end