class AddDocumentLocale < ActiveRecord::Migration
  def self.up
    # Locale used for setting a documents locale should it be needed.
    add_column :documents, :locale, :string, :length => 8, :default => nil
  end

  def self.down
    remove_column :documents, :locale
  end
end
