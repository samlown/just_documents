# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
    if logged_in?
      redirect_back_or_default('/')
    end
  end

  def create
    logout_keeping_session!
    if using_open_id?
      open_id_authentication
    else
      password_authentication(params[:email], params[:password])
    end
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin(identity)
    flash[:error] = "Couldn't log you in as '#{identity}'"
    logger.warn "Failed login for '#{identity}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def open_id_authentication
    authenticate_with_open_id do |result, identity_url|
      @identity_url = identity_url
      if result.successful?
        if self.current_user = User.find_by_identity_url(identity_url)
          flash[:notice] = "Logged in successfully"
          redirect_back_or_default('/')
          return
        else
          # flash[:notice] = "Please create a new account"
          session[:identity_url] = identity_url
          redirect_to new_user_url
          return
        end
      else
        flash.now[:warning] = "Invalid Open ID login identity"
      end
      render :action => 'new'
    end
  end

  def password_authentication email, password
    user = User.authenticate(email, password)
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin(params[:email])
      flash[:warning] = "Invalid login details"
      @email       = params[:email]
      @remember_me = params[:remember_me]
      params[:regular] = 1
      render :action => 'new'
    end
  end

end
