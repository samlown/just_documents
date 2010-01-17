class CommentsController < ApplicationController

  before_filter :load_document
  before_filter :editor_required, :only => [:update, :destroy] 

  def create
    respond_to do |format|
      format.js do
        @comment = @document.comments.build(params[:comment])
        @comment.ip_address = request.remote_ip
        msg = nil 
        if logged_in?
          @comment.user = current_user
          @comment.published_at = Time.now
        else
          msg = "Thank you, you're comment has been received but will not be published until we've had chance to check it."
        end

        if @comment.save
          render :json => {:state => 'win', :id => "comment_#{@comment.id}", :view => (logged_in? ? render_to_string(:partial => 'show') : nil), :msg => msg}
        else
          msg = "There was a problem saving your comment, please check you've entered everything correctly."
          render :json => {:state => 'fail', :msg => msg}
        end
      end
      format.html { render :action => 'denied' }
    end
  end

  def update
    respond_to do |format|
      format.js do
        @comment = @document.comments.find(params[:id])
        @comment.published_at = params[:comment][:published_at] 

        if @comment.update_attributes(params[:comment])
          render :json => {:state => 'win', :id => "comment_#{@comment.id}", :view => render_to_string(:partial => 'show')}
        else
          render :json => {:state => 'fail', :id => "comment_#{@comment.id}", :msg => "Unable to save comment"}
        end
      end
      format.html { render :action => 'denied' }
    end
  end

  def destroy
    @comment = @document.comments.find(params[:id])
    respond_to do |format|
      if (@comment.destroy)
        format.js do
          render :json => {:state => 'win'}
        end
      else
        format.js do
          render :json => {:state => 'fail', :msg => "Unable to delete the comment"}
        end
      end
    end
  end

  protected

    def load_document
      @document = Document.find_by_slug(params[:document_id])
    end

end
