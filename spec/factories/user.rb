FactoryGirl.define do
  factory :user do
    email                 "personal@example.com"
    password              "12345678"
    password_confirmation "12345678"
    edm_accept            "0"
    agreement             "1"
  end
end