class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :nonce
      t.string :encrypted_number
      t.string :owner
      t.date :expiration_date
      t.string :credit_network
      t.timestamps null: false
    end
  end
end
