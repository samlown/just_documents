# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  before_filter :prepare_theme
  before_filter :set_locale

  def prepare_theme
    @current_theme = "default"
  end

  def current_user_is_admin?
    logged_in? and current_user.is_admin?
  end

  def current_user_is_editor?
    logged_in? and current_user.is_editor?
  end

  def set_locale
    I18n.locale = params[:locale] || cookies['locale'] || extract_locale_from_accept_language_header || I18n.default_locale
    cookies['locale'] = I18n.locale.to_s
  end

  def admin_required
    current_user_is_admin? or redirect_to(root_url)
  end

  def editor_required
    current_user_is_editor? or redirect_to(root_url)
  end

  # This is a hack to allow json reponses to be sent through an iframe!
  # Meant to be used in conjunction with jquery.form plugin.
  def render_textarea_json(data)
    headers["Content-Type"] = "text/html; charset=utf-8"
    render :text => "<textarea>#{data.to_json}</textarea>" 
  end

  private

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first
  end 


end
