class DocumentRevision < ActiveRecord::Base

  belongs_to :document

  # Store of the current revision.
  serialize :attribs, Hash

  before_validation :prepare_from_document

  #validates_presence_of :document_id
  #validates_presence_of :version

  named_scope :newest_first, :order => 'document_revisions.version DESC'

  protected

    def prepare_from_document
      raise "Must provide document_id when creating a new document_revision" if document.nil?
      if version.nil?
        self.version = self.class.count(:conditions => ['document_id = ?', document_id]) + 1
      end
      if attribs.nil? or attribs.empty?
        self.attribs = document.attributes
      end
    end

end
