class ChangeAddressIdToBeNullableInUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_null :users, :address_id, true
  end
end

