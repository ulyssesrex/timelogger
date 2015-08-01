json.array!(@grants) do |grant|
  json.extract! grant, :id, :name, :comments, :ppd_hours_percent, :ppd_hours, :organization_id
  json.url grant_url(grant, format: :json)
end
