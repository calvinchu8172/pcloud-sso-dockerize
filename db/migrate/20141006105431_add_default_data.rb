class AddDefaultData < ActiveRecord::Migration
  def change
    Product.create(id: 26, name: "NSA310S", model_name: "NSA310S", asset_file_name: "device_icon_gray_1bay.png", asset_content_type: "image/png", asset_file_size: 2497, asset_updated_at:  "2014-10-04 12:28:07", pairing_file_name: "animate_1bay.gif", pairing_content_type: "image/gif", pairing_file_size: 9711, pairing_updated_at: "2014-10-04 12:28:08")
    Product.create(id: 27, name: "NSA320S", model_name: "NSA320S", asset_file_name: "device_icon_gray_2bay.png", asset_content_type: "image/png", asset_file_size: 2412, asset_updated_at:  "2014-10-04 12:28:37", pairing_file_name: "animate_2bay.gif", pairing_content_type: "image/gif", pairing_file_size: 10116, pairing_updated_at: "2014-10-04 12:28:37")
    Product.create(id: 28, name: "NSA325", model_name: "NSA325", asset_file_name: "device_icon_gray_2bay.png", asset_content_type: "image/png", asset_file_size: 2412, asset_updated_at:  "2014-10-04 12:29:05", pairing_file_name: "animate_nsa325.gif", pairing_content_type: "image/gif", pairing_file_size: 12266, pairing_updated_at: "2014-10-04 12:29:06")
    Product.create(id: 29, name: "NSA325 v2", model_name: "NSA325 v2", asset_file_name: "device_icon_gray_2bay.png", asset_content_type: "image/png", asset_file_size: 2412, asset_updated_at:  "2014-10-04 12:29:41", pairing_file_name: "animate_2bay.gif", pairing_content_type: "image/gif", pairing_file_size: 10116, pairing_updated_at: "2014-10-04 12:29:41")
    Product.create(id: 30, name: "NAS540", model_name: "NAS540", asset_file_name: "device_icon_gray_4bay.png", asset_content_type: "image/png", asset_file_size: 2631, asset_updated_at:  "2014-10-04 12:29:59", pairing_file_name: "animate_4bay.gif", pairing_content_type: "image/gif", pairing_file_size: 9495, pairing_updated_at: "2014-10-04 12:29:59")
    Domain.create(domain_name: Settings.environments.ddns)
  end
end
