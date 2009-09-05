class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.references :user
      t.integer :parent_id
      t.integer :position
      t.string :slug, :null => false
      t.string :title
      t.string :layout, :length => 32, :null => false
      t.text :summary
      t.text :content
      t.string :author
      t.text :metadata
      t.boolean :allow_comments, :default => false
      t.boolean :allow_pingbacks, :default => false
      t.datetime :published_at
      t.datetime :hidden_at
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
