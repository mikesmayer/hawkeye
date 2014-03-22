class CreateP42MenuItems < ActiveRecord::Migration
  def change
    create_table :p42_menu_items do |t|
      t.float :gross_price
      t.integer :menu_item_group_id
      t.string :name
      t.integer :recipe_id
      t.integer :revenue_group_id
      t.boolean :count_meal
      t.time :count_meal_start
      t.time :count_meal_end
      t.integer :count_meal_modifier

      t.timestamps
    end
  end
end
