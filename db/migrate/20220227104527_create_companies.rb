class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :company_number
      t.date :date_of_creation
      t.string :type
      t.string :jurisdiction
      t.string :company_name
      t.integer :address_id
      t.string :company_status

      t.timestamps
    end
  end
end
