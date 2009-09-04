# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user_is_admin?
    logged_in? and current_user.is_admin?
  end

  def text_filter(text)
    @controller.text_filter(text)
  end

end
