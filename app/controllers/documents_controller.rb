class DocumentsController < ApplicationController
  
  before_filter :editor_required, :except => [:show, :index]
  before_filter :load_parent_document

  def index
    respond_to do |format|
      format.html { redirect_to document_url(:id => 'home') }
      format.js do
        base = Document
        if !params[:q].blank? then base = base.search(params[:q]) end
        if !params[:layout].blank? then base = base.layout_is(params[:layout]) end
        @documents = base.paginate(:page => params[:page], :per_page => 20, :order => 'slug')
        if logged_in?
          render :json => { :view => render_to_string(:partial => 'index') }
        else
          render :text => 'fail'
        end
      end
    end
  end

  def show
    if logged_in?
      @document = Document.find_by_slug(params[:id])
    else
      @document = Document.published.not_hidden.find_by_slug(params[:id]) 
    end
    respond_to do |format|
      prepare_document unless @document.nil?
      if @document.nil?
        format.html { render :action => 'not_found', :status => 404 }
      else
        format.html
        format.atom { render :action => 'show', :content_type => 'application/atom+xml' }
      end
    end
  end


  def new
    locale = I18n.locale.to_s != I18n.default_locale.to_s ? I18n.locale.to_s : nil
    @document = Document.new(:slug => params[:slug], :layout => params[:layout], :locale => locale)
    @document.parent = @parent_document unless @parent_document.nil?
    @document.user = current_user
    respond_to do |format|
      format.js do
        render :json => {:state => 'win', :view => render_to_string(:partial => 'edit', :locals => {:document => @document})}
      end
    end
  end

  def create
    @document = Document.new(params[:document])
    update
  end
  

  def edit
    @document = Document.find_by_slug(params[:id])
    respond_to do |format|
      format.js do
        render :json => {:state => 'win', :view => render_to_string(:partial => 'edit', :locals => {:document => @document})}
      end
    end
  end

  # This could get messy, but update always assumes ID is provided, not slug.
  # Hence avoiding problems changing slug.
  def update
    @document = Document.find(params[:id]) unless @document
    result = nil
    @document.attributes = params[:document]
    @document.revision_user = current_user
    if params[:event] == 'publish'
      result = @document.publish!
    elsif params[:event] == 'unpublish'
      result = @document.unpublish!
    else
      result = @document.save
    end
    respond_to do |format|
      if result
        format.js do
          result = {
            :state => 'win', :url => document_url(@document), 
            :redirect => params[:parent_id].blank?, # Redirect if no parent id, to cope with slug changes.
            :id => "document_#{@document.id}"
          }
            
          if (params[:event] == 'draft')
            result[:view] = render_to_string(:partial => 'edit', :locals => {:document => @document})
          end
          render :json => result
        end
      else
        format.js do
          result = { :state => 'fail', :msg => "Error: "+@document.errors.map{|a,msg| msg}.first, :id => "document_#{@document.id}" }
          if params[:event] != 'action'
            result[:view] = render_to_string(:partial => 'edit', :locals => {:document => @document})
          end
          render :json => result 
        end
      end
    end

  end

  def destroy
    @document = Document.find(params[:id])
    respond_to do |format|
      if @document.destroy
        format.js { render :json => {:state => 'win'} }
      else
        format.js { render :json => {:state => 'fail', :msg => "Unable to delete the document"} }
      end
    end
  end

  def sort
    params[:document].each_with_index do |d_id, i|
      document = Document.find(d_id)
      document.no_revision = true
      document.update_attribute(:position, i + 1)
    end
    respond_to do |format|
      format.js { render :json => {:state => 'win'} }
    end
  end

  protected

    def load_parent_document
      @parent_document = Document.find(params[:parent_id]) unless params[:parent_id].blank?
    end

    # Prepare any additional details the document requires to be shown on the page.
    # Operations should be performed according to the documents layout.
    def prepare_document
      case @document.layout
      when '' 
      end
    end

end
