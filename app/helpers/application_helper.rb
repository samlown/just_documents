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

  #
  # Pre-filter Textile documents for wiki-like links and contents
  #
  def textile_wiki_filter(text)
    # Replace wiki links with URLs
    text.gsub /(".+"):(\S+\w)/ do |s|
      title = $1; link = $2
      title + ':' + (link =~ /^\/|([a-z0-9]{2,}:\/\/)/i ? link : document_url(link))
    end
  end

end
