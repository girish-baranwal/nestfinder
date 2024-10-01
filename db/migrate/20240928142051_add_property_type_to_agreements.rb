class AddPropertyTypeToAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :agreements, :property_type, :integer, default: 0
  end
end
