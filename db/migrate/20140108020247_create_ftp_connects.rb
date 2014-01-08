class CreateFtpConnects < ActiveRecord::Migration
  def change
    create_table :ftp_connects do |t|
      t.string :server
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
