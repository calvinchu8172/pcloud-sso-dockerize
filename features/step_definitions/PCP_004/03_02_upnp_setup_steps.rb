Given(/^a user visit UPnP setup page with module version 2 device$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
  @pairing.device.module_version['upnp'] = 2
  @module_version = @pairing.device.module_version['upnp']
  # visit upnp_path(@pairing.device.encoded_id)
  visit "/#{@module_version}/upnp/#{@pairing.device.encoded_id}"
end

Given(/^the page will waiting for connection with device$/) do
  @upnp_session = get_upnp_session
end

When(/^the user changed UPnP setting$/) do
  wait_server_response
end

When(/^the device was offline$/) do
  set_upnp_status(@upnp_session, "failure")
end

When(/^the device was online the device will response service list$/) do
  service_list = [{ "service_name":"FTP",
                    "status":true,
                    "enabled":true,
                    "description":"FTP configuration",
                    "wan_port":"22",
                    "lan_port":"22",
                    "path":"ftp://ip:port" },
                  { "service_name":"DDNS",
                    "status":true,
                    "enabled":true,
                    "description":"DDNS configuration",
                    "wan_port":"1000",
                    "lan_port":"",
                    "path":"" },
                  { "service_name":"HTTP",
                    "status":false,
                    "enabled":false,
                    "description":"HTTP configuration",
                    "wan_port":"8000",
                    "lan_port":"80",
                    "path":"http://ip:port" }].to_json.gsub("\n", "")
  set_upnp_status(@upnp_session, "form", service_list)
  wait_server_response
end


When(/^device response the failure result of the modified service$/) do
  service_list = JSON.parse(@upnp_session['service_list'])
  service_list.map! {|service|
    service['service_name'] == 'HTTP' ? service.merge({'error_code' => '798'}) : service
  }
  service_list = service_list.to_json.gsub("\n", "")
  set_upnp_status(@upnp_session, "form", service_list)
  wait_server_response
end

When(/^device response the success result of the modified service$/) do
  service_list = JSON.parse(@upnp_session['service_list'])
  service_list.map! {|service|
    service['service_name'] == 'HTTP' ? service.merge({'error_code' => ''}) : service
  }
  service_list = service_list.to_json.gsub("\n", "")
  set_upnp_status(@upnp_session, "updated", service_list)
  wait_server_response
end

Then(/^the session status now should be "(.*?)"$/) do |status|
  step "the page will waiting for connection with device"
  expect(@upnp_session['status']).to eq status
end

Then(/^the upnp session flow should starting reload service list from device$/) do
  step 'the session status now should be "start"'
end

When(/^the services was success updated$/) do
  wait_server_response
  set_upnp_status(@upnp_session, "updated")
end

Then(/^it should not do anything on UPnP setup page$/) do
  expect(page).to have_content I18n.t("warnings.settings.upnp.sync")
end

Then(/^the user should see "(.*?)" message on UPnP setup page$/) do |msg|
  wait_server_response
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

When(/^user click "(.*?)"$/) do |arg1|
  step "the page will waiting for connection with device"
  step "the device was online the device will response service list"
  click_on(I18n.t("labels.settings.upnp.table_head6"))
end

Then(/^user should see port numbers of each service$/) do
  expect(all(:xpath, '//table/tbody/tr/td/input')[0].value).to have_content('22')
  expect(all(:xpath, '//table/tbody/tr/td/input')[2].value).to have_content('8000')
end

Then(/^the "(.*?)" button should be replaced by "(.*?)" button$/) do |arg1, arg2|
  expect(page).to have_content(I18n.t("labels.settings.upnp.table_head7"))
end

When(/^the device was online the device will response service list with used wan port list$/) do
  service_list = [{ "service_name":"FTP",
                    "status":true,
                    "enabled":true,
                    "description":"FTP configuration",
                    "wan_port":"22",
                    "lan_port":"22",
                    "path":"ftp://ip:port" },
                  { "service_name":"DDNS",
                     "status":false,
                     "enabled":false,
                     "description":"DDNS configuration",
                     "wan_port":"1000",
                     "lan_port":"",
                     "path":"" },
                  { "service_name":"HTTP",
                     "status":false,
                     "enabled":false,
                     "description":"HTTP configuration",
                     "wan_port":"8008",
                     "lan_port":"80",
                     "path":"http://ip:port" }].to_json.gsub("\n", "")
  @used_wan_port_list_array = ["1000", "8000", "9000"]
  used_wan_port_list = @used_wan_port_list_array.to_json.gsub("\n", "")
  set_upnp_status(@upnp_session, "form", service_list, used_wan_port_list)
  wait_server_response

end

Then(/^the port number of all disabled service will be given a random number between (\d+) and (\d+)$/) do |arg1, arg2|
  click_on(I18n.t("labels.settings.upnp.table_head6"))
  expect(all(:xpath, '//table/tbody/tr/td/input')[1].value.to_i).to be_between(arg1.to_i, arg2.to_i).inclusive
end

Then(/^those port numbers should not in the used wan port list$/) do
  a = all(:xpath, '//table/tbody/tr/td/input')[1].value
  expect(@used_wan_port_list_array).not_to include(a)
end

When(/^the user changed UPnP port setting of a disabled service$/) do
  click_on(I18n.t("labels.settings.upnp.table_head6"))
  all(:xpath, '//table/tbody/tr/td/input')[2].set("8888")
end

Given(/^the user clicked the checkbox to enabled the service$/) do
  all(:xpath, '//table/tbody/tr/td/div/div/label')[2].click
end

Then(/^the user should see "(.*?)" text in "(.*?)" column of the service on UPnP setup page$/) do |text, column|
  if @module_version == 2
    expect(find(:xpath, "//table/tbody/tr[@ng-controller='ServiceCtrl']/td[6]/span[@ng-switch]/span[@ng-switch-when='#{text.downcase}']")).to have_content text
  elsif @module_version == 1
    expect(find(:xpath, "//table/tbody/tr/td[5]/span[@ng-switch]/span[@ng-switch-when='#{text.downcase}']")).to have_content text
  end
end

Then(/^the checkbox value of the service should be "(.*?)"$/) do |checkbox_value|
  expect(find("#check2", :visible => :all).checked?.to_s).to eq checkbox_value
end

Then(/^the status value of the service should be "(.*?)"$/) do |status_value|
  if @module_version == 2
    expect(page).to have_xpath("//table/tbody/tr[@ng-controller='ServiceCtrl']/td[2]/span[@ng-switch-when='#{status_value}']")
  elsif @module_version == 1
    expect(page).to have_xpath("//table/tbody/tr/td[2]/span[@ng-switch-when='#{status_value}']")
  end
end


def get_upnp_session
  # redis = Redis.new
  redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  @session_index = redis.GET("upnp:session:index")
  UpnpSession.find(@session_index).session.all
end

def set_upnp_status(upnp_session, status, service_list = "", used_wan_port_list = "")
  upnp_session['status'] = status
  upnp_session['service_list'] = service_list
  upnp_session['used_wan_port_list'] = used_wan_port_list
  UpnpSession.find(@session_index).session.update(upnp_session)
  wait_server_response
  upnp_session
end
