class CreateTacosMealCountRules < ActiveRecord::Migration
  def change
    create_table :tacos_meal_count_rules do |t|
      t.integer :menu_item_id
      t.float :meal_modifier
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
