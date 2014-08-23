class AddAgeGroupToProducts < ActiveRecord::Migration
  def change
    add_column :products, :age_group, :string
  end
end
