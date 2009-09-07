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
end
