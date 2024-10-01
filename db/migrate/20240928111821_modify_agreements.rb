class ModifyAgreements < ActiveRecord::Migration[6.1]
  def change
    add_column :agreements, :city, :string

    remove_column :agreements, :rent_amount, :decimal
  end
end

