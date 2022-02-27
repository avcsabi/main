class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.string :country
      t.string :locality
      t.string :postal_code
      t.string :address_line_1
      t.string :address_line_2

      t.timestamps
    end
  end
end
