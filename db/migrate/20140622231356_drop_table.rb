class DropTable < ActiveRecord::Migration
  def up
    drop_table :p42_ticket_items
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
