class AddPaymentMethodType < ActiveRecord::Migration

  def change
    add_column :payment_methods, :payment_method_type, :string
  end

end
