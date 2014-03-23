class CreateP42Discounts < ActiveRecord::Migration
  def change
    create_table :p42_discounts do |t|
      t.boolean :active
      t.string :name

      t.timestamps
    end
  end
end
