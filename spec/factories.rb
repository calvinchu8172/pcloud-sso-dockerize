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
    association :full_domain, factory: :full_domain
  end
  factory :identity do
    association :user_id,     factory: :user_id
    association :provider,    factory: :provider
    association :uid,         factory: :uid
  end
end