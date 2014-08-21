FactoryGirl.define do
  factory :user do
    email                 "personal@example.com"
    password              "12345678"
    password_confirmation "12345678"
    edm_accept            "0"
    agreement             "1"
  end
  factory :device do
    sequence(:serial_number) { |n| "1234567890#{n}"}
    sequence(:mac_address) { |n| "00:00:00:00:00:0#{n}"}
    model_name "NSA325"
    firmware_version "V4.70(AALS.0)_GPL_20140820"
  end
end