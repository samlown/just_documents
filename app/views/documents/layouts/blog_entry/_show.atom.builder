xml.entry do
  xml.id document.id
  xml.title document.title
  xml.summary text_filter(document.summary), :type => 'html'
  xml.content text_filter(document.content), :type => 'html'
  xml.updated document.updated_at.iso8601
  xml.published document.published_at.iso8601
  xml.link document_url(document), :rel => 'alternate'
end
