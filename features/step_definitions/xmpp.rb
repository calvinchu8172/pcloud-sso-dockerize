

# Given(/^the device with get::$/) do |table|
#   @table = table.rows_hash
# end

# When /^the device request POST (.*)$/ do |path|
#   @hostname = 'http://127.0.0.1:3000'
#   @path = @hostname + path
#   post(@path, @table)
# end

# Then(/^I will get http code and (.*)$/) do |json|
#   puts 'HTTP code: ' + @this_status = last_response.status.to_s

#   @xmpp_table = JSON.parse(last_response.body) 
#   @xmpp_table = JSON.pretty_generate(@xmpp_table)

#   if @this_status[0] == "2"
#     puts @xmpp_table 
#   elsif @this_status[0] == "4" || @this_status[0] == "5"
#     puts @xmpp_table
#   else
#     puts ''
#   end

# end

Then /I use xmpp_acount to ack bot/ do 
  @username = @xmpp_acount["xmpp_account"]
  @password = @xmpp_acount["xmpp_password"]

  # @xmpp_table["xmpp_bots"] = ["bot01@aphpxmpp.pcloud.ecoworkinc.com/robot"]
  # clean the hash
  # Ref.http://stackoverflow.com/a/13972656
  @bot = @xmpp_acount["xmpp_bots"]*","
  @bot = @bot.gsub('/robot', '')

  Bot.new(@username, @password, @bot).connect
end

Then(/^I will get message from bot$/) do
  pending # express the regexp above with the code you wish you had
end
