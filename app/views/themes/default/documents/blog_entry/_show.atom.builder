xml.entry do
  xml.id document.id
  xml.title document.title
  xml.summary RedCloth.new(textile_wiki_filter(document.summary)).to_html, :type => 'html'
  xml.content RedCloth.new(textile_wiki_filter(document.content)).to_html, :type => 'html'
  xml.updated document.updated_at.iso8601
  xml.published document.published_at.iso8601
  xml.link document_url(document), :rel => 'alternate'
end
