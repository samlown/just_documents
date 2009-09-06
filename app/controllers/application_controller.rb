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

  def prepare_theme
    @current_theme = "default"
  end

  def text_filter(text)
    RedCloth.new(text).to_html
  end
end
