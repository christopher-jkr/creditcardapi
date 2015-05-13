# DB Scheme for users
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |u|
      u.text :hashed_password, :encrytped_address, :encrypted_fullname,
             :encrypted_dob, :nonce, :email, :username, :salt
      u.timestamps null: false
    end
  end
end
