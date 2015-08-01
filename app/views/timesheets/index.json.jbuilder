json.array!(@timesheets) do |timesheet|
  json.extract! timesheet, :id, :user_id, :comments, :start_time, :end_time
  json.url timesheet_url(timesheet, format: :json)
end
