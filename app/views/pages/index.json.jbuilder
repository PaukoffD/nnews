json.array!(@pages) do |page|
  json.extract! page, :id, :title, :ref, :published
  json.url page_url(page, format: :json)
end
