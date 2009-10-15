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

  def form_revision_comment(f, document)
    render_partial_from_theme "documents/shared/form_revision_comment", :locals => {:f => f, :document => document}
  end

  # Show advanced document options according to the array of required options.
  def form_advanced_options(f, document, *list)
    render_partial_from_theme "documents/shared/form_advanced_options", :locals => {:f => f, :document => document, :list => list}
  end

  def form_revision_history(f, document)
    render_partial_from_theme "documents/shared/form_revision_history", :locals => {:f => f, :document => document}   
  end

end
