class CreateTacosMenuItems < ActiveRecord::Migration
  def change
    create_table :tacos_menu_items do |t|
      t.integer :menu_item_group_id
      t.string :name
      t.integer :recipe_id

      t.timestamps
    end
  end
end
