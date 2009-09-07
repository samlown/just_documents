xml.instruct! :xml, :version => "1.0"
xml << render(:partial => "themes/#{@current_theme}/documents/#{@document.layout}/show", :locals => {:document => @document})
