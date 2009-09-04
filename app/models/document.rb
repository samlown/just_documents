class Document < ActiveRecord::Base

  has_many :comments

  acts_as_tree
  acts_as_list :scope => :parent_id
  acts_as_taggable_on :tags

  serialize :metadata, Hash

  named_scope :published, :conditions => ['documents.published_at IS NOT NULL']
  named_scope :not_published, :conditions => ['documents.published_at IS NULL']

  named_scope :hidden, :conditions => ['documents.hidden_at IS NOT NULL']
  named_scope :not_hidden, :conditions => ['documents.hidden_at IS NULL']

  named_scope :layout_is, lambda {|layout| {:conditions => ['documents.layout = ?', layout]}}

  validates_uniqueness_of :title, :message => "A document with this title already exists"

  validates_presence_of :slug
  validates_uniqueness_of :slug
  validates_format_of :slug, :with => /^[\w\d_]+$/

  before_validation :prepare_slug

  def initialize(attribs = {})
    attribs[:metadata] ||= { }
    super(attribs)
  end

  def published?
    !published_at.nil?
  end
  def publish!
    update_attribute(:published_at, Time.now)
  end
  def unpublish!
    update_attribute(:published_at, nil)
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

  protected

    def prepare_slug
      if slug.blank?
        self.slug = title.to_s.gsub(/[^\w\d_]/, '_').downcase
      end
    end

end
