# DB Scheme for users
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |u|
      u.string :username, :email, :fullname
      u.data :dob
      u.text :hashed_password, :address
      u.timestamps null: false
    end
  end
end
