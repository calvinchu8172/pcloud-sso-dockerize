When(/^NAS send a GET request to \/resource\/(\d+)\/vendor_devices\/crawl with:$/) do |arg1|
  # pending # express the regexp above with the code you wish you had
  # data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/vendor_devices/crawl"

  post path
end