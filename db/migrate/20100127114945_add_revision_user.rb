class AddRevisionUser < ActiveRecord::Migration
  def self.up
    add_column :document_revisions, :user_id, :integer
  end

  def self.down
    remove_column :document_revisions, :user_id
  end
end
