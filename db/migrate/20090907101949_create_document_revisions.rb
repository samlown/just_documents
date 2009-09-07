class CreateDocumentRevisions < ActiveRecord::Migration
  def self.up
    create_table :document_revisions do |t|
      t.references :document
      t.string :comment 
      t.integer :version
      t.boolean :minor, :default => false
      t.text :attribs
      t.timestamps
    end
  end

  def self.down
    drop_table :document_revisions
  end
end
