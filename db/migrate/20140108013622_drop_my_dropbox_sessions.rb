class DropMyDropboxSessions < ActiveRecord::Migration
  def change
  	drop_table :my_dropbox_sessions
  end
end
