class CreateDocumentTranslations < ActiveRecord::Migration
  def self.up
    create_table :document_translations do |t|
      t.references :document
      t.string :locale, :limit => 8 
      t.string :title
      t.text :summary
      t.text :content
      t.string :author
      t.timestamps
    end
  end

  def self.down
    drop_table :document_translations
  end
end
