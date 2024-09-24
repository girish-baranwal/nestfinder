class RenameAddressIdInUsersAndProperties < ActiveRecord::Migration[6.1]
  def change
    # Renaming the address_id column in the users table to role
    rename_column :users, :address_id, :role

    # Renaming the address_id column in the properties table to title
    rename_column :properties, :address_id, :title
  end
end
