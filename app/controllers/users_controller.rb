class UsersController < ApplicationController

  before_filter :login_required, :except => [:create, :new]
  before_filter :admin_required, :only => [:index]

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
    @user.role = params[:user][:role] unless params[:user][:role].blank?
    respond_to do |format|
      format.js do
        if @user.save
          if current_user_is_admin?
            index(:state => 'win')
          else
            render :json => {:state => 'win'}
          end
        else
          if current_user_is_admin?
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
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      session[:identity_url] = nil
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end
end
