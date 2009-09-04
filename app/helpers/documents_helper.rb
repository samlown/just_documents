module DocumentsHelper

  # Handle pagination of a documents children. Will only show published and not hidden
  # child documents if the user is not logged in.
  #
  # Options are passed to the paginate call, the following are set by default:
  #
  #  :page      Current page parameter
  #  :order     'published_at DESC'
  #  :per_page  10
  #
  def paginate_documents documents, options = {}
    options.reverse_merge!( :page => params[:page], :order => 'published_at DESC', :per_page => 10 )
    documents.paginate(options)
  end

end
