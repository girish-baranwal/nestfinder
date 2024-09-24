class AddAddressFieldsToProperties < ActiveRecord::Migration[6.1]
  def change
    add_column :properties, :address_line_1, :string
    add_column :properties, :address_line_2, :string
    add_column :properties, :city, :string
    add_column :properties, :postal_code, :int
  end
end
