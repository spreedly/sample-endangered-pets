class CreateOrders < ActiveRecord::Migration

  def change
    create_table :orders do |t|
      t.string :order_type
      t.belongs_to :payment_method
      t.integer :quantity
      t.integer :amount
      t.string :state, default: :created

      t.timestamps
    end
  end

end
