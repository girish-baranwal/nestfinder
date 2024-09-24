class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :property, null: false, foreign_key: true
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
