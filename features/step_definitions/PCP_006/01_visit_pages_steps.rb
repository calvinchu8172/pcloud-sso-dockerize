Given(/^the user is in the sign in page$/) do
	visit root_path
end

Then(/^the user should see the help page$/) do
  expect(page.current_path).to eq("/help")
end

Then(/^the user should see the support page$/) do
  expect(page.current_url).to eq("http://www.zyxel.com/form/Support_Feedback.shtml")
end