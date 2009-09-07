xml.instruct! :xml, :version => "1.0"
xml << render_partial_from_theme("documents/#{@document.layout}/show", :locals => {:document => @document})
