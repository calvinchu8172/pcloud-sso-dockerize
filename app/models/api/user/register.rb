class Api::User::Register < Api::User
  attr_accessor :certificate_serial, :signature, :app_key, :os
  validates_with SslValidator, signature_key: [:email, :certificate_serial]
  validates_presence_of :email, :password, :certificate_serial, :signature, message: "invalid parameters"
  validates_presence_of :app_key, if: :app_key_or_os_need_presence?
  validates :os, inclusion: { in: %w(0 1 2),
    message: "invalid parameters" },
    if: :app_key_or_os_need_presence?

  after_save :update_mobile_info


  private
    def update_mobile_info
			self.app_info.bulk_set({app_key: app_key, os: os})
    end

    def app_key_or_os_need_presence?
  	  !os.blank? or !app_key.blank?
    end
end