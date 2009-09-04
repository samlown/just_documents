class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :document
      t.references :user
      t.string :title
      t.string :email
      t.string :name
      t.text :content
      t.datetime :published_at
      t.datetime :hidden_at
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
