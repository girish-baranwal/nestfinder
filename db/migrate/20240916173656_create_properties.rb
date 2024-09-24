class CreateProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.decimal :price
      t.text :description
      t.string :status
      t.json :images
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
