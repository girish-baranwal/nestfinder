class UpdateAgreement < ActiveRecord::Migration[6.1]
  def change
    add_column :agreements, :rent_amount, :decimal
    add_column :agreements, :deposit_amount, :decimal
    add_column :agreements, :maintenance_amount, :decimal
    add_column :agreements, :duration, :integer
    add_column :agreements, :tenant_name, :decimal
    add_column :agreements, :tenant_email, :decimal

    remove_column :agreements, :manual_property_address, :string
    remove_column :agreements, :manual_property_city, :string
    remove_column :agreements, :manual_property_postal_code, :string
    remove_column :agreements, :tenant_id, :string
    remove_column :agreements, :property_type, :string
  end
end
