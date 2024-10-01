class AddManualPropertyFieldsToAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :agreements, :manual_property_address, :string
    add_column :agreements, :manual_property_city, :string
    add_column :agreements, :manual_property_postal_code, :string
  end
end
