class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.integer :parent_id
      t.integer :position
      t.string :slug, :null => false
      t.string :title
      t.string :layout, :length => 32, :null => false
      t.text :summary
      t.text :content
      t.string :author
      t.text :metadata
      t.datetime :published_at
      t.datetime :hidden_at
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
