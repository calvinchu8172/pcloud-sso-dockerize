Given(/^a user visit UPnP setup page$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
  visit upnp_path(@pairing.device.encoded_id)
end

Given(/^the page will waiting for connection with device$/) do
  @upnp_session = get_upnp_session
end

Given(/^the user changed UPnP setting$/) do
  wait_server_response
end

When(/^the device was offline$/) do
  set_upnp_status(@upnp_session, "failure")
end

When(/^the device was online the device will response service list$/) do
  service_list = ('[{"service_name":"FTP",
                     "status":true,
                     "enabled":true,
                     "description":"FTP configuration",
                     "wan_port":"22",
                     "lan_port":"22",
                     "path":"ftp://ip:port"},
                    {"service_name":"DDNS",
                     "status":true,
                     "enabled":false,
                     "description":"DDNS configuration",
                     "wan_port":"",
                     "lan_port":"",
                     "path":""},
                    {"service_name":"HTTP",
                     "status":true,
                     "enabled":false,
                     "description":"HTTP configuration",
                     "wan_port":"8000",
                     "lan_port":"80",
                     "path":"http://ip:port"}]').gsub("\n", "")
  set_upnp_status(@upnp_session, "form", service_list)
  wait_server_response
end

When(/^the services was success updated$/) do
  wait_server_response
  set_upnp_status(@upnp_session, "updated")
end

Then(/^it should not do anything on UPnP setup page$/) do
  expect(page).to have_content I18n.t("warnings.settings.upnp.sync")
end

Then(/^the user should see "(.*?)" message on UPnP setup page$/) do |msg|
  expect(page).to have_content(msg)
end

Then(/^the user will see the confirm message about cancel UPnP setup$/) do
  expect(page).to have_content I18n.t("warnings.settings.upnp.cancel_instruction")
end

Then(/^the user will go back to setup flow$/) do
  expect(page).to have_content I18n.t("warnings.settings.upnp.sync")
end

Then(/^the user should see service list$/) do
  wait_server_response
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head1"))
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head2"))
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head3"))
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head4"))
end

Then(/^the user will redirect to My Devices page after cancel$/) do
  expect(page.current_path).to eq authenticated_root_path
end


def get_upnp_session
  redis = Redis.new
  @session_index = redis.GET("upnp:session:index")
  UpnpSession.find(@session_index).session.all
end

def set_upnp_status(upnp_session, status, service_list = "")
  upnp_session['status'] = status
  upnp_session['service_list'] = service_list
  UpnpSession.find(@session_index).session.update(upnp_session)
  wait_server_response
  upnp_session
end