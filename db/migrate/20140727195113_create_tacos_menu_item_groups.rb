class CreateTacosMenuItemGroups < ActiveRecord::Migration
  def change
    create_table :tacos_menu_item_groups do |t|
      t.string :name
      t.integer :default_meal_modifier

      t.timestamps
    end
  end
end
