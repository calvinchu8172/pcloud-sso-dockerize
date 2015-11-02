class Ddns < ActiveRecord::Base

  enum status: { used: 0, warning: 1 }

  belongs_to :device
  belongs_to :domain
  before_save :save_ip_addr

  MODULE_NAME = 'ddns'

  # revert ip address
  def get_ip_addr
    IPAddr.new(self.ip_address.to_s.to_i(16), Socket::AF_INET).to_s
  end

  # transform ip address to binary
  def save_ip_addr
    self.ip_address = IPAddr.new(self.ip_address).to_i.to_s(16).rjust(8, "0")
  end
end
