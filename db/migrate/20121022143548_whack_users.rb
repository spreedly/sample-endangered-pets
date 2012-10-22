class WhackUsers < ActiveRecord::Migration
  def up
    drop_table :users
  end

  def down
    create_table :users do |t|
      t.string :email, :crypted_password, :salt
      t.timestamps
    end
  end
end
