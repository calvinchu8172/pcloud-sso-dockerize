FactoryGirl.define do

  factory :user do
    sequence(:email)          {|n| "personal#{n}@example.com"}
    password                  "12345678"
    password_confirmation     "12345678"
    edm_accept                "0"
    agreement                 "1"
  end
  factory :device do
    sequence(:serial_number)  { |n| "1234567890#{n}"}
    sequence(:mac_address)    { |n| "#{n}".rjust(12, "0")}
    firmware_version          "V4.70(AALS.0)_GPL_20140820"
    ip_address                IPAddr.new("192.168.50.1").to_i.to_s(16).rjust(8, "0")
    association :product_id,  factory: :product_id
  end
  factory :pairing do
    association :user_id,     factory: :user_id
    association :device_id,   factory: :device_id
    ownership                 "0"
  end
  factory :ddns do
    ip_address                "127.0.0.1"
    association :device_id,   factory: :device_id
    association :domain_id,   factory: :domain_id
  end
  factory :identity do
    association :user_id,     factory: :user_id
    association :provider,    factory: :provider
    association :uid,         factory: :uid
  end
  factory :invitation do
    share_point                "share_folder"
    permission                 2
    expire_count               5
  end
  factory :accepted_user do
    status                     0
  end
  factory :api_user, class: Api::User do
    sequence(:email)          {|n| "personal#{n}@example.com"}
    password                  "12345678"
    password_confirmation     "12345678"
    edm_accept                "0"
    agreement                 "1"
  end
  factory :oauth_user, class: Api::User::OauthUser do
    sequence(:email)          {|n| "personal#{n}@example.com"}
    password                  "12345678"
    password_confirmation     "12345678"
    edm_accept                "0"
    agreement                 "1"
  end
  factory :api_device, class: Api::Device do
    sequence(:serial_number)  { |n| "0123456789#{n}"}
    sequence(:mac_address)    { |n| "#{n}".rjust(12, "0")}
    firmware_version          "V4.70(AALS.0)_GPL_20140820"
    ip_address                IPAddr.new("192.168.50.1").to_i.to_s(16).rjust(8, "0")
    model_class_name          "NSA310S"
    association :product_id,  factory: :product_id
  end

  factory :oauth_client_app, class: Doorkeeper::Application do
    sequence(:name)  { |n| "oauth_client_app_#{n}"}
    redirect_uri 'https://app.com/callback'
  end
  factory :oauth_access_token, class: Doorkeeper::AccessToken do
    sequence(:resource_owner_id) { |n| n }
    application_id            1
    expires_in                6.hours
  end
  factory :access_grant, class: Doorkeeper::AccessGrant do
    sequence(:resource_owner_id) { |n| n }
    application_id            1
    redirect_uri 'https://app.com/callback'
    expires_in                600
  end
  factory :vendor, class: Vendor do
    id                        1
    name                      "ASI"
  end
  factory :vendor_product, class: VendorProduct do
    product_class_name        "IPCAM"
    model_class_name          "C11W"
  end
  factory :vendor_device, class: VendorDevice do
    udid                      "B01F81700417"
    mac_address               "AABBCCDDEEFF"
    device_name               "ABCDE12345678"
    firmware_version          "V1"
    serial_number             "12345678"
    ipv4_lan                  IPAddr.new("192.168.12.79").to_i.to_s(16).rjust(8, "0")
    online_status             1
  end


end