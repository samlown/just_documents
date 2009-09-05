class CommentsController < ApplicationController

  before_filter :load_document
  before_filter :login_required, :only => [:update] 

  def create
    @comment = @document.comments.build(params[:comment])
    @comment.ip_address = request.remote_ip
    if logged_in?
      @comment.user = current_user
      @comment.published_at = Time.now
    end

    respond_to do |format|
      if @comment.save
        flash[:notice] = "Thank you for your comment, it will be published as soon as we've checked its okay"
        format.html { redirect_to document_url(@document)+'#comments' }
      else
        format.html { render :action => 'fail' }
      end
    end
  end

  def update
    @comment = @document.comments.find(params[:id])
    if logged_in?
      @comment.published_at = params[:comment][:published_at] 
    end

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to document_url(@document)+'#comments' }
        format.js do 
          render :json => {:status => 'WIN', :id => "comment_#{@comment.id}"}
        end
      else
        format.html { render :action => 'fail' }
        format.js do
          render :json => {:status => 'FAIL', :id => "comment_#{@comment.id}", :msg => "Unable to save comment"}
        end
      end
    end
  end

  protected

    def load_document
      @document = Document.find_by_slug(params[:document_id])
    end

end
