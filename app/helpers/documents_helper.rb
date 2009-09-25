module DocumentsHelper

  # Handle pagination of a documents children. Will only show published and not hidden
  # child documents if the user is not logged in.
  #
  # Automatically adds the for_current_locale filter.
  #
  # Options are passed to the paginate call, the following are set by default:
  #
  #  :page      Current page parameter
  #  :order     'position ASC'
  #  :per_page  10
  #
  def paginate_documents documents, options = {}
    options.reverse_merge!( :page => params[:page], :order => 'position ASC', :per_page => 10 )
    documents.for_current_locale.paginate(options)
  end

end
