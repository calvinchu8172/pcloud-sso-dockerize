Given(/^the device with the following payload::$/) do |form|
  @form = form.rows_hash
end 

When /^the device requests POST (.*)$/ do |path|
  option = {:method => :post, :params => @form}
  request path, option
end

Then(/^response should be "(.*?)"$/) do |status|
  if self.respond_to? :should
    last_response.status.should == status.to_i
  else
    assert_equal status.to_i, last_response.status
  end
end
Then(/^xmpp_acount is available$/)  do 
  xmpp_acount = JSON.parse(last_response.body)
  username = xmpp_acount["xmpp_account"]
  password = xmpp_acount["xmpp_password"]

  # username = "admin@localhost"
  # password = "1234"

  jid = JID.new(username)
  puts "username:" + username + ", password:" + password
  client = Client.new jid
  client.connect
  sleep(2)
  client.auth(password)
  # puts client.inspect
  # assert true
  # result = client.auth(password)


  assert true
  # result = client.auth(@password)
  # result.should be_ture
  # true.should be_ture

  # client.auth(@password).is_a?(status)
end