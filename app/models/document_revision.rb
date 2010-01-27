class DocumentRevision < ActiveRecord::Base

  belongs_to :document
  belongs_to :user

  # Store of the current revision.
  serialize :attribs, Hash

  before_validation :prepare_from_document

  #validates_presence_of :document_id
  #validates_presence_of :version

  named_scope :newest_first, :order => 'document_revisions.version DESC'

  named_scope :for_current_locale, lambda {{:conditions => ['document_revisions.locale IS NULL OR document_revisions.locale = ?', I18n.locale.to_s]}}

  attr_accessor :skip_attribs

  protected

    def prepare_from_document
      raise "Must provide document_id when creating a new document_revision" if document.nil?
      if version.nil?
        self.version = self.class.count(:conditions => ['document_id = ?', document_id]) + 1
      end
      self.locale = I18n.locale.to_s
      unless minor 
        if attribs.nil? or attribs.empty?
          self.attribs = document.attributes.dup.stringify_keys!
        end
      end
    end

end
