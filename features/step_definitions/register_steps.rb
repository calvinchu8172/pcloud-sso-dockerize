Given(/^the device with get::$/) do |table|
  @table = table.rows_hash
end

When /^the device request POST (.*)$/ do |path|
  @path = 'http://127.0.0.1:3000' + path
  post(@path, @table)
end

Then(/^I will get http code and (.*)$/) do |json|
  
  puts 'The http code is ' + @this_status = last_response.status.to_s
  # @this_status = "4"

  if @this_status[0] == "2"
    puts JSON.parse(last_response.body) 
  elsif @this_status[0] == "4" || @this_status[0] == "5"
    puts JSON.parse(last_response.body) 
  else
    puts ''
  end
  
end