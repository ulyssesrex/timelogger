json.array!(@grantholdings) do |grantholding|
  json.extract! grantholding, :id, :grant_id, :user_id
  json.url grantholding_url(grantholding, format: :json)
end
