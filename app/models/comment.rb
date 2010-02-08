class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :document
  
  validates_presence_of :author, :message => "Author cannot be blank"
  validates_length_of :author, :within => 2..100, :message => "Author must have between 2 and 100 characters"
  
  validates_presence_of :email, :message => "Email address required"
  validates_format_of  :email, :with => Authentication.email_regex, :message => "Invalid email address" 

  validates_presence_of :content, :message => "Missing the message body"

  named_scope :published, :conditions => ['comments.published_at IS NOT NULL AND comments.published_at <= ?', Time.now]
  named_scope :not_published, :conditions => ['comments.published_at IS NULL OR comments.published_at > ?', Time.now]

  named_scope :notifyable, :conditions => ['comments.notify_by_email = ?', true]

  attr_accessible :title, :email, :author, :web, :content, :notify_by_email

  def published?
    !published_at.nil? && published_at <= Time.now 
  end
  def publish!
    update_attribute(:published_at, Time.now)
  end
  def unpublish!
    update_attribute(:published_at, nil)
  end

  # include the name in the email
  def full_email
    "#{self.author} <#{self.email}>"
  end

  def self.new_for_user(user)
    self.new(
      :email => user.email,
      :author => user.name,
      :web => user.web
    )
  end

end
