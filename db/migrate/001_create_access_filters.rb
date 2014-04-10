class CreateAccessFilters < ActiveRecord::Migration
  def change
    create_table :access_filters do |t|
      t.references :user
      t.boolean :web
      t.boolean :api
      t.text	:cidrs
    end
  end
end