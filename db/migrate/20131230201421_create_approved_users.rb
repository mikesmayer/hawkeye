class CreateApprovedUsers < ActiveRecord::Migration
  def change
    create_table :approved_users do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
