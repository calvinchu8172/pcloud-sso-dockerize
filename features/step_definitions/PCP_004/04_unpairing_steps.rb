Given(/^the user visits unpairing page$/) do
  visit "/unpairing/index/#{@pairing.id}"
end

Then(/^the user should see "(.*?)" message on unpairing page$/) do |msg|
  expect(page).to have_content(msg)
end

