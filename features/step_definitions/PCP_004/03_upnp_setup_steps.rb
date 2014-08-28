Given(/^a user visit UPnP setup page$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
  visit upnp_path(@pairing.device_id)
end

Given(/^the page will waiting for connection with device$/) do
  @upnp_session = get_upnp_session
end

Given(/^the user changed UPnP setting$/) do
  wait_server_response
end

When(/^the device was offline$/) do
  set_upnp_status(@upnp_session, "failure")
  sleep 300
end

When(/^the device was online the device will response service list$/) do
  service_list = '[{"service_name":"FTP",
                    "status":true,
                    "enabled":true,
                    "description":"FTP configuration",
                    "port":"22",
                    "path":"ftp://wanip:port"},
                   {"service_name":"DDNS",
                    "status":true,
                    "enabled":false,
                    "description":"DDNS configuration",
                    "port":"",
                    "path":""},
                   {"service_name":"HTTP",
                    "status":true,
                    "enabled":false,
                    "description":"HTTP configuration",
                    "port":"80",
                    "path":"http://wanip:port"}]'
  set_upnp_status(@upnp_session, "form", service_list)
end

When(/^the services was success updated$/) do
  set_upnp_status(@upnp_session, "updated")
  wait_server_response
end

Then(/^the user should see "(.*?)" message on UPnP setup page$/) do |msg|
  expect(page).to have_content(msg)
end

Then(/^the user should see service list$/) do
  wait_server_response
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head1"))
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head2"))
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head3"))
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head4"))
end

def get_upnp_session
  upnp_session = UpnpSession.where("device_id = ? and user_id = ?", @pairing.device_id, @user.id).last
end

def set_upnp_status(upnp_session, status, service_list = "")
  upnp_session.status = status
  upnp_session.service_list = service_list
  upnp_session.save
  upnp_session
end