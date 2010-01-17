class AddUserWeb < ActiveRecord::Migration
  def self.up
    add_column :users, :web, :string
  end

  def self.down
    remove_column :users, :web
  end
end
