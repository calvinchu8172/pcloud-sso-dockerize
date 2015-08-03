Given(/^a user visit Package setup page$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
  @device = @pairing.device
  visit package_path(@pairing.device.encoded_id)
end

When(/^the package page will wait for connection with device$/) do
  @package_session = get_package_session
end

Then(/^the user should see "(.*?)" message on Package setup page$/) do |msg|
  expect(page).to have_content(msg)
end

When(/^the device of Package was offline$/) do
  set_package_status(@package_session, "failure")
end

When(/^the device was online the device will response package list$/) do
  package_list = ('[
   {
       "package_name": "WORDPRESS",
       "status": true,
       "requires": ["PHP-MySQL-phpMyAdmin"],
       "enabled": false,
       "description": ["a1","a2","a3"],
       "version": "001zypkg013"
   },
   {
       "package_name": "PHP-MySQL-phpMyAdmin",
       "status": true,
       "requires": [],
       "enabled": false,
       "description": ["b1.","b2.","b3"],
       "version": "002zypkg013"
   },
   {
       "package_name": "gallery",
       "status": false,
       "requires": ["PHP-MySQL-phpMyAdmin"],
       "enabled": false,
       "description": ["C1","C2","C3"],
       "version": "003zypkg013"
   },
   {
       "package_name": "Transmission",
       "status": false,
       "requires": [],
       "enabled": false,
       "description": ["d1","d2","d3"],
       "version": "004zypkg013"
   }
  ]').gsub("\n", "")

  set_package_status(@package_session, "form", package_list)
  wait_server_response
end

Then(/^the user should see package name list$/) do
  wait_server_response
  expect(page).to have_content(I18n.t("labels.settings.package.table_head1"))
  expect(page).to have_content(I18n.t("labels.settings.package.table_head2"))
  expect(page).to have_content(I18n.t("labels.settings.package.table_head3"))
  expect(page).to have_content(I18n.t("labels.settings.package.table_head4"))
end

When(/^the user changed Package setting$/) do
  wait_server_response
end

When(/^the Package services was success updated$/) do
  wait_server_response
  set_package_status(@package_session, "updated")
end

Then(/^the user will see the confirm message about cancel Package setup$/) do
  expect(page).to have_content I18n.t("warnings.settings.package.cancel_instruction")
end

Then(/^the user will go back to Package setup flow$/) do
  expect(page).to have_content I18n.t("warnings.settings.package.sync")
end

Then(/^it should not do anything on Package setup page$/) do
  expect(page).to have_content I18n.t("warnings.settings.package.sync")
end

Then(/^the user will redirect to My Devices page after confirm$/) do
  expect(page.current_path).to eq("/personal/index")
end

Then(/^the user will redirect to the UPnP Setup page$/) do
  current_url = URI.decode(page.current_path).chomp
  module_version = @pairing.device.get_module_version('upnp')
  expect_url = URI.decode("/#{module_version}/upnp/" + @pairing.device.encoded_id).chomp
  expect(current_url).to eq(expect_url)
end


def get_package_session
  redis = Redis.new
  @session_index = redis.GET("package:session:index")
  PackageSession.find(@session_index).session.all
end

def set_package_status(package_session, status, package_list = "")
  package_session['status'] = status
  package_session['package_list'] = package_list
  PackageSession.find(@session_index).session.update(package_session)
  wait_server_response
  package_session
end
