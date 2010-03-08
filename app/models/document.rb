class Document < ActiveRecord::Base

  has_many :comments, :dependent => :delete_all
  has_many :comment_users, :through => :comments, :source => :user
  has_many :revisions, :class_name => 'DocumentRevision', :dependent => :delete_all

  has_many :translations, :class_name => 'DocumentTranslation'
  translate_columns :title, :summary, :content, :author 

  belongs_to :user

  acts_as_tree
  acts_as_list :scope => :parent_id
  acts_as_taggable_on :tags

  serialize :metadata, Hash

  named_scope :published, :conditions => ['documents.published_at IS NOT NULL AND documents.published_at <= ?', Time.now]
  named_scope :not_published, :conditions => ['documents.published_at IS NULL OR documents.published_at > ?', Time.now]

  named_scope :hidden, :conditions => ['documents.hidden_at IS NOT NULL']
  named_scope :not_hidden, :conditions => ['documents.hidden_at IS NULL']

  named_scope :layout_is, lambda {|layout| {:conditions => ['documents.layout = ?', layout]}}

  named_scope :for_current_locale, lambda { {:conditions => ['(documents.locale IS NULL OR documents.locale = ?) OR documents.locale = ?', '', I18n.locale.to_s]} }

  named_scope :ordered, :order => 'position ASC'

  named_scope :search, lambda {|q| {:conditions => ['documents.title LIKE ? OR documents.slug LIKE ?', "%#{q.to_s}%", "%#{q.to_s}%"]}}

  validates_uniqueness_of :title, :message => "A document with this title already exists"

  validates_presence_of :slug, :message => "Missing the slug"
  validates_uniqueness_of :slug, :message => "Document title is not unique"
  validates_format_of :slug, :with => /^[a-zA-Z0-9\_\-]+$/, :message => "Document slug appears to contain invalid characters"

  validates_presence_of :layout, :message => "Cannot create a document without a layout"

  before_validation :prepare_slug

  before_save :prepare_revision
  after_save :save_revision
  attr_accessor :revision_comment, :revision_user, :minor_revision, :no_revision

  def initialize(attribs = {})
    attribs[:metadata] ||= { }
    super(attribs)
  end

  def published?
    !published_at.nil? && published_at <= Time.now 
  end
  def publish!
    return false if published?
    self.published_at ||= Time.now
    self.minor_revision = false
    self.revision_comment ||= "Published"
    save
  end
  def unpublish!
    return false unless published?
    self.published_at = nil
    self.minor_revision = true
    self.revision_comment ||= "Un-published"
    save
  end

  def hide!
    update_attribute(:hidden_at, Time.now)
  end
  def unhide!
    update_attribute(:hidden_at, nil)
  end

  def to_param
    slug
  end

  def allow_any_comments
    allow_comments or allow_pingbacks
  end

  def minor_revision
    @minor_revision == "1" || @minor_revision == true
  end

  def destroy
    super
    self.parent.revisions.create(:comment => "Destroyed child \"#{self.title}\"", :minor => true) unless self.parent.nil?
  end

  protected

    def prepare_slug
      if slug.blank?
        self.slug = title.urlize
      end
    end

    def prepare_revision
      @parent_revision = self.parent.revisions.build(:comment => "Added new child \"#{self.title}\"", :minor => true, :user => (revision_user || user)) unless self.parent.nil?
    end
    def save_revision
      unless no_revision # || !changed? # Disabled, as causes problem with translated columns
        self.revisions.create(:comment => revision_comment, :user => (revision_user || user), :minor => minor_revision)
        @parent_revision.save unless @parent_revision.nil? 
      end
    end

end
