class CreateMyDropboxes < ActiveRecord::Migration
  def change
    create_table :my_dropboxes do |t|
      t.string :app_key
      t.string :app_secret
      t.string :access_token
      t.string :account_name
      t.boolean :authorized

      t.timestamps
    end
  end
end
