class RememberRecurring < ActiveRecord::Migration

  def change
    add_column :payment_methods, :recurring, :boolean, default: false
  end

end
