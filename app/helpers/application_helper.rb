# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def current_user_is_admin?
    @controller.current_user_is_admin?
  end

  def current_user_is_editor?
    @controller.current_user_is_editor?
  end
end
