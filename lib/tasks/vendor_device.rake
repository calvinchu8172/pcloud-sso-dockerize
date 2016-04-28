namespace :vendor do

  task :create => :environment do
    3.times do |i|
      VendorDevice.create(
        user_id: 1,
        udid: 'aaaaaaaa',
        vendor_id: 1,
        vendor_product_id: 1,
        mac_address: '0023f8311041',
        mac_range: '12',
        mac_address_secondary: 'BBCCDDEEFF',
        mac_range_secondary: '14',
        device_name: 'NAS540',
        firmware_version: '540_datecode_20150615_myZyXELCloud-Agent_1.0.0',
        serial_number: 'TEMPSERIALNUM0000',
        ipv4_lan: '192.168.1.1',
        ipv6_lan: 'aa. bb. cc. dd',
        ipv4_wan: '',
        ipv4_lan_secondary: '',
        ipv6_lan_secondary: '',
        ipv4_wan_secondary: '',
        online_status: 1,
        meta: { "network": "WIFI",
                 "microphoneSupport": "1",
                 "speakerSupport": "1",
                 "recTagSupport": "0",
                 "ircutSupport": "1",
                 "ptzSupport": "-1"
              }.to_json,
        )
    end

  end
end