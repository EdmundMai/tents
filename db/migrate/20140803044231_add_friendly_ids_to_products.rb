class AddFriendlyIdsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :slug, :string, unique: true
    add_index :products, :slug
  end
end
