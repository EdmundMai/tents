class AddInfoToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :email, :string
    add_column :vendors, :street_address, :string
    add_column :vendors, :street_address2, :string
    add_column :vendors, :zip_code, :string
    add_column :vendors, :phone_number, :string
    add_column :vendors, :state_id, :integer
    add_column :vendors, :city, :string
  end
end
