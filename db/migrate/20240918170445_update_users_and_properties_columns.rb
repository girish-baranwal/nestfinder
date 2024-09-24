class UpdateUsersAndPropertiesColumns < ActiveRecord::Migration[6.1]
  def change
    # Remove the foreign key constraint from the role column in users table
    remove_foreign_key :users, column: :role

    # Change role column to string (varchar)
    change_column :users, :role, :string

    # Change title column to string (varchar) in properties table
    change_column :properties, :title, :string
  end
end

