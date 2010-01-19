# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user_is_admin?
    @controller.current_user_is_admin?
  end

  def current_user_is_editor?
    @controller.current_user_is_editor?
  end

  # Render a partial using the theme's view. If not available in the current theme,
  # try using the default. The provided view should not include a / at the beginning.
  def render_partial_from_theme(view, options = {})
    theme_view = ""
    [@current_theme, 'default'].uniq.each do |theme|
      theme_view = "themes/#{theme}/#{view}"
      begin
        return render(options.update(:partial => theme_view))
      rescue ActionView::MissingTemplate
        # try again
      end
    end
    raise "Unable to find view in themes: #{theme_view}"
  end

  def render_document(document, options = {})
    options.reverse_merge!(:document => document)
    render_partial_from_theme "documents/#{document.layout}/show", :locals => options 
  end

  #
  # Pre-filter Textile documents for wiki-like links and contents
  #
  def textile_wiki_filter(text)
    # Replace wiki links with URLs
    text.gsub /(".+"):(\S+\w)/ do |s|
      title = $1; link = $2
      title + ':' + (link =~ /^\/|([a-z0-9]{2,}:(\/\/)?)/i ? link : document_url(link))
    end
  end

  # Render the document actions partial and set a few defaults in preparation.
  # Actions will only be shown if the user is logged in and has permissions.
  #
  # Options include:
  #   :force => Boolean; When true, always show the actions, otherwise only show if its the active document or child of
  #   :draggable => boolean; show the drag handle
  #
  def document_actions(document = nil, options = {})
    return unless current_user_is_editor?
    document ||= @document
    options.reverse_merge!(:document => document, :force => false, :draggable => false)
    render :partial => 'documents/actions', :locals => options
  end

  #
  # Provide an action for adding new child documents. Will only 
  # provide the form when the current user is an editor.
  #
  # Layout should be provided along with a title, otherwise the default is "page".
  #
  def document_add_child(document, options = {})
    return unless current_user_is_editor?
    options.reverse_merge!(:layout => 'page', :title => "Create a new sub page")
    content_tag(:ul,
      content_tag(:li,
        link_to( image_tag('icons/plus.png'),
          new_document_url(:layout => options[:layout], :parent_id => document.id),
          :class => 'button documentFormAction', :title => options[:title]
        )
      ),
      :class => 'sideActions forNewItems'
    )
  end


end
