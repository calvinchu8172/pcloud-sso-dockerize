Given(/^the device with get::$/) do |table|
  @table = table.rows_hash
end

When /^the device request POST (.*)$/ do |path|
  @hostname = 'http://127.0.0.1:3000'
  @path = @hostname + path
  post(@path, @table)
end

Then(/^I will get http code and (.*)$/) do |json|
  puts 'The http code is ' + @this_status = last_response.status.to_s

  # Backup for document status
  #
  # if @this_status[0] == "2"
  #   puts JSON.parse(last_response.body) 
  # elsif @this_status[0] == "4" || @this_status[0] == "5"
  #   puts JSON.parse(last_response.body) 
  # else
  #   puts ''
  # end

  puts @xmpp_table = JSON.parse(last_response.body) 

end

When(/^I ack bot$/) do

  # Backup for dev env 
  #
  puts @username = @xmpp_table["xmpp_account"].gsub('/device', '')
  @password = @xmpp_table["xmpp_password"]
  puts @bot      = @xmpp_table["xmpp_bots"].to_s.gsub('/robot', '')

  # Set client and client data for reset password issue
  # puts " It's test env, not real pass data"
  # @username = 'd127001-01@aphpxmpp.pcloud.ecoworkinc.com/device'.gsub('/device', '')
  # @password = 'jSBFVbnKzD'
  # @bot      = 'bot01@aphpxmpp.pcloud.ecoworkinc.com/robot'.gsub('/robot', '')
  Bot.new(@username, @password, @bot).connect
end

Then(/^I will get message from bot$/) do
  pending # express the regexp above with the code you wish you had
end
