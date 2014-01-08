class DropTableMyDropboxes < ActiveRecord::Migration
  def change
  	drop_table :my_dropboxes
  end
end
