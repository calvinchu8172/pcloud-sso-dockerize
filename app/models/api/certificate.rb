class Api::Certificate < ActiveRecord::Base

  def self.find_public_by_serial serial
    certificate = self.find_by serial: serial
    return OpenSSL::X509::Certificate.new(certificate.content).public_key
  end
end