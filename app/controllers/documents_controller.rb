class DocumentsController < ApplicationController
  
  before_filter :login_required, :except => [:show, :index]
  before_filter :load_parent_document

  def index
    redirect_to document_url(:id => 'home') 
  end

  def show
    if logged_in?
      @document = Document.find_by_slug(params[:id])
    else
      @document = Document.published.not_hidden.find_by_slug(params[:id]) 
    end
    respond_to do |format|
      if @document.nil?
        format.html { render :action => 'not_found' }
      else
        format.html
      end
    end
  end


  def new
    @document = Document.new(:slug => params[:slug], :layout => params[:layout])
    @document.parent = @parent_document unless @parent_document.nil?
    respond_to do |format|
      format.js do
        render :partial => 'new', :locals => {:document => @document}
      end
    end
  end

  def create
    @document = Document.new(params[:document])
    respond_to do |format|
      if @document.save
        format.js do
          render :json => { :status => 'WIN', :url => [@document], :id => "document_#{@document.id}" }
        end
      else
        format.js do
          render :json => { :status => 'FAIL', :view => render_to_string(:partial => 'new', :locals => {:document => @document}) }
        end
      end
    end

  end
  

  def edit
    @document = Document.find_by_slug(params[:id])
    respond_to do |format|
      format.js do
        render :partial => 'edit', :locals => {:document => @document}
      end
    end
  end

  def update
    @document = Document.find_by_slug(params[:id])
    respond_to do |format|
      if @document.update_attributes(params[:document])
        format.js do
          result = { :status => 'WIN', :url => document_url(@document), :id => "document_#{@document.id}" }
          render :json => result
        end
      else
        format.js do
          result = { :status => 'FAIL', :msg => "Unable to update the document", :id => "document_#{@document.id}" }
          if params[:event] != 'action'
            result[:view] = render_to_string(:partial => 'edit', :locals => {:document => @document})
          end
          render :json => result 
        end
      end
    end

  end

  def destroy
    @document = Document.find_by_slug(params[:id])
    respond_to do |format|
      if @document.destroy
        render :json => { :status => 'WIN' }
      else
        render :json => { :status => 'FAIL', :msg => "Unable to delete the document" }
      end
    end
  end

  protected

    def load_parent_document
      slug = params[:document_id] || params[:parent_id]
      @parent_document = Document.find_by_slug(slug) unless slug.blank?
    end

end
