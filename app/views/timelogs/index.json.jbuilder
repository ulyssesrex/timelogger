json.array!(@timelogs) do |timelog|
  json.extract! timelog, :id, :user_id, :comments, :start_time, :end_time
  json.url timelog_url(timelog, format: :json)
end
