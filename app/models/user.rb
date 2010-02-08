require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  validates_presence_of     :email, :message => 'models.user.email.required'
  validates_length_of       :email, :within => 6..100, :too_short => 'models.user.email.too_short', :too_long => 'models.user.email.too_long'
  validates_uniqueness_of   :email, :message => 'models.user.email.taken'
  validates_format_of       :email, :with => Authentication.email_regex, :message => 'models.user.email.format' 

  validates_format_of       :name, :with => Authentication.name_regex, :allow_nil => true, :message => 'models.user.name.format'
  validates_length_of       :name, :maximum => 100, :too_long => "models.user.name.too_long"
  validates_presence_of     :name, :message => "models.user.name.required"
  
  attr_accessible :email, :name, :web, :password, :password_confirmation

  named_scope :admins, :conditions => ['role IN (?)', 'admin']
  named_scope :editors, :conditions => ['role IN (?)', 'editor']

  named_scope :active, :conditions => ['state IN (?)', 'active']
  named_scope :receive_comment_notifications, :conditions => ['comment_notify = ?', true]

  serialize :preferences, Hash

  def self.roles
    [
      ['visitor', ''],
      ['editor', 'editor'],
      ['admin', 'admin']
    ]
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find_by_email(email.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def full_email
    "#{self.name} <#{self.email}>"
  end

  def is_admin?
    role == 'admin'
  end
  def is_editor?
    ['admin', 'editor'].include?(role)
  end

  def role_name
    self.class.roles.rassoc(role)[0]
  end

  def password_required?
    identity_url.blank? && (crypted_password.blank? || !password.blank?)
  end

  protected

    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end

end
