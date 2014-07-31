# Given(/^the device with the following payload::$/) do |form|
#   @form = form.rows_hash
# end 

# When /^the device requests POST (.*)$/ do |path|
#   option = {:method => :post, :params => @form}
#   request path, option
# end

# Then(/^response should be "(.*?)"$/) do |status|
#   if self.respond_to? :should
#     last_response.status.should == status.to_i
#   else
#     assert_equal status.to_i, last_response.status
#   end
# end