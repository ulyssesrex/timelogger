json.array!(@organizations) do |organization|
  json.extract! organization, :id, :name, :description, :keyword
  json.url organization_url(organization, format: :json)
end
