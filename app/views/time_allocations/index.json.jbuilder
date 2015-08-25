json.array!(@time_allocations) do |time_allocation|
  json.extract! time_allocation, :id, :grantholding_id, :timelog_id, :hours, :date, :comments
  json.url time_allocation_url(time_allocation, format: :json)
end
