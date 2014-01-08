class CreateDropboxSessions < ActiveRecord::Migration
  def change
    create_table :my_dropbox_sessions do |t|
      t.string :app_key
      t.string :app_secret
      t.string :account_email
      t.boolean :authorized, default: false
      t.text :serialized_session
 
      t.timestamps
    end
  end
end

