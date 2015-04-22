class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |cc|
      cc.string :number, :expiration_date, :owner, :credit_network
    end
  end
end
