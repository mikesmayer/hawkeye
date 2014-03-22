class CreateP42MenuItemGroups < ActiveRecord::Migration
  def change
    create_table :p42_menu_item_groups do |t|
      t.string :name
      t.integer :default_meal_modifier

      t.timestamps
    end
  end
end
