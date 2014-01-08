class AddSerializedSessionToMyDropboxSessions < ActiveRecord::Migration
  def change
    add_column :my_dropboxes, :serialized_session, :text
  end
end
