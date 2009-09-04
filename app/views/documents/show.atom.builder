xml.instruct! :xml, :version => "1.0"
render :partial => "documents/layouts/#{@document.layout}/show", :locals => {:document => @document}
