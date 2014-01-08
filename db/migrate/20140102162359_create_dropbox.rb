class CreateDropbox < ActiveRecord::Migration
  def change
    create_table :dropboxes do |t|
      t.string :app_key
      t.string :app_secret
      t.text :access_token
      t.string :account_name
      t.boolean :authorized, default: false      
 
      t.timestamps
    end
  end
end
