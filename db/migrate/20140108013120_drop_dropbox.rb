class DropDropbox < ActiveRecord::Migration
  def change
  	drop_table :dropboxes
  end
end
