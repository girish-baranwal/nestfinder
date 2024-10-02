class ChangeTenantFieldsToAgreements < ActiveRecord::Migration[6.1]
  def change
    change_column :agreements, :tenant_name, :string
    change_column :agreements, :tenant_email, :string
    change_column_null :agreements, :start_date, false
    change_column_null :agreements, :end_date, false
  end
end

# dates to be non null