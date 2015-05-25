class Api::User::Register < Api::User
  attr_accessor :certificate_serial, :signature, :app_key, :os
  validates_with SslValidator, signature_key: [:email, :password, :certificate_serial]
  validates_presence_of :email, :password, :certificate_serial, :signature, message: "invalid parameters"
  validates_presence_of :app_key, if: :app_key_os_need_validate?
  validates :os, inclusion: { in: %w(0 1 2),
    message: "invalid parameters" },
    if: :app_key_os_need_validate?


  def app_key_os_need_validate?
  	!os.blank? or !app_key.blank?
  end
end