Given(/^the device with get::$/) do |table|
  @table = table.rows_hash
end

When /^the device request POST (.*)$/ do |path|
  puts @path = path
  post @path, @table
end

Then /I will get HTTP: (\w+) and (\w+)/ do |http_code, xmpp_acount|
  @http_code = http_code
  @last_http_code = last_response.status.to_s

  if @http_code[0] != @last_http_code[0]
    puts "The response HTTP code: #{@last_http_code} are not match" 
    break
  else
    puts "The response HTTP code: #{@last_http_code}"
  end

  @xmpp_acount = JSON.parse(last_response.body)
  puts  JSON.pretty_generate(@xmpp_acount)
end

