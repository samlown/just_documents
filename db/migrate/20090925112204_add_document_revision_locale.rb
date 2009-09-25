class AddDocumentRevisionLocale < ActiveRecord::Migration
  def self.up
    add_column :document_revisions, :locale, :string, :length => 8
  end

  def self.down
    remove_column :document_revisions, :locale
  end
end
