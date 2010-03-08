class UsersController < ApplicationController

  before_filter :login_required, :except => [:create, :new, :activate]
  before_filter :admin_required, :only => [:index, :destroy]

  def index(json = { })
    @users = User.paginate :per_page => 50, :page => params[:page]
    respond_to do |format|
      format.js do
        render :json => json.update(:view => render_to_string(:partial => 'index'))
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    if @user.id == current_user.id || current_user_is_admin?
      respond_to do |format|
        format.js do
          render :json => {:state => 'win', :view => render_to_string(:partial => 'edit')}
        end
      end
    end
  end

  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    if current_user_is_admin?
      @user.role = params[:user][:role] unless params[:user][:role].blank?
      @user.identity_url = params[:user][:identity_url]
    end
    respond_to do |format|
      format.js do
        if @user.save
          if current_user_is_admin? && @user.id != current_user.id
            index(:state => 'win')
          else
            render :json => {:state => 'win'}
          end
        else
          if current_user_is_admin? && @user.id != current_user.id
            index(:state => 'fail')
          else
            render :json => {:state => 'fail', :view => render_to_string(:partial => 'edit'), :msg => 'Check your details!'}
          end
        end
      end
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.identity_url = session[:identity_url]
    @user.role = "admin" if User.count == 0
    success = @user && @user.save
    if success && @user.errors.empty?
      @user.register!
      Notifier.deliver_user_signup(@user, url_for(:controller => 'users', :action => 'activate', :activation_code => @user.activation_code))
      User.admins.each { |admin| Notifier.deliver_admin_user_signup(admin, @user) }
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      @stored_location = stored_location
      session[:identity_url] = nil
    else
      render :action => 'new'
    end
  end

  def activate
    @user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    @stored_location = stored_or_default_location(root_url)
    if @user
      if logged_in? && @user.id != current_user.id
        logout_keeping_session!
      end
      if (!params[:activation_code].blank?) && !@user.active?
        @user.activate!
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    respond_to do |format|
      format.js do
        if @user != current_user
          if @user.destroy
            render :json => {:state => 'win', :redirect_to => users_url}
          else
            render :json => {:state => 'fail', :view => render_to_string(:partial => 'edit')}
          end
        end
      end
    end
  end

end
