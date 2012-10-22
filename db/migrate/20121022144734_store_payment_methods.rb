class StorePaymentMethods < ActiveRecord::Migration
  def up
    create_table :payment_methods do |t|
      t.string :email, :token
      t.timestamps
    end
  end

  def down
    drop_table :payment_methods
  end
end
