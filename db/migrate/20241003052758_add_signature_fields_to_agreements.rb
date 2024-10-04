class AddSignatureFieldsToAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :agreements, :owner_signature, :string
    add_column :agreements, :owner_signed_at, :datetime
    add_column :agreements, :tenant_signature, :string
    add_column :agreements, :tenant_signed_at, :datetime
  end
end
