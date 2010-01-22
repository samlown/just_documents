children = @document.children.published.for_current_locale.not_hidden.layout_is('blog_entry')
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do |feed|
  xml.title @document.title
  xml.summary RedCloth.new(@document.summary).to_html, :type => 'html'
  xml.link document_url(@document), :rel => 'alternate'
  xml.updated children.find(:first, :order => 'published_at DESC').updated_at.iso8601

  children.find(:all, :order => 'published_at DESC', :limit => 10).each do |entry|
    xml << render_partial_from_theme("documents/blog_entry/show", :locals => {:xml => xml, :document => entry})
  end
end
