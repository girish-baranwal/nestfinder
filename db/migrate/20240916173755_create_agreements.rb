class CreateAgreements < ActiveRecord::Migration[6.1]
  def change
    create_table :agreements do |t|
      t.references :property, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: { to_table: :users }
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.date :start_date
      t.date :end_date
      t.decimal :rent_amount
      t.string :status

      t.timestamps
    end
  end
end
