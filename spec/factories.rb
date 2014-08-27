FactoryGirl.define do
  factory :user do
    email                 "personal@example.com"
    password              "12345678"
    password_confirmation "12345678"
    edm_accept            "0"
    agreement             "1"
  end
  factory :device do
    sequence(:serial_number)  { |n| "1234567890#{n}"}
    sequence(:mac_address)    { |n| "00:00:00:00:00:0#{n}"}
    model_name                "NSA325"
    firmware_version          "V4.70(AALS.0)_GPL_20140820"
  end
  factory :device_session do
    association :device_id, factory: :device_id
    xmpp_account          "personal@example.com"
    password              "12345678"
    ip                    "127.0.0.1"
  end
  factory :pairing_session do
    sequence(:expire_at)  { |n| Time.now + 12.minutes}
    status                "start"
    association :user_id, factory: :user_id
    association :device_id, factory: :device_id
  end
  factory :ddns_session do
    status                "start"
    association :device_id, factory: :device_id
    association :full_domain, factory: :full_domain
  end
  factory :pairing do
    association :user_id, factory: :user_id
    association :device_id, factory: :device_id
  end
  factory :ddns do
    ip_address            "127.0.0.1"
    association :device_id, factory: :device_id
    association :full_domain, factory: :full_domain
  end
  factory :identity do
    association :user_id, factory: :user_id
    association :provider, factory: :provider
    association :uid, factory: :uid
  end
end