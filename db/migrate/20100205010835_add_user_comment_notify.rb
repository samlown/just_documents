class AddUserCommentNotify < ActiveRecord::Migration
  def self.up
    add_column :users, :comment_notify, :boolean, :default => true
    add_column :comments, :notify_by_email, :boolean, :default => true
  end

  def self.down
    remove_column :users, :comment_notify
    remove_column :comments, :notify_by_email
  end
end
