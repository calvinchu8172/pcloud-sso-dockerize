When(/^NAS send a GET request to \/resource\/(\d+)\/vendor_devices\/crawl with:$/) do |arg1|
  path = '//' + Settings.environments.api_domain + "/resource/1/vendor_devices/crawl"

  post path
end