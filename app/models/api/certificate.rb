class Api::Certificate < ActiveRecord::Base

  def self.find_public_by_serial serial
    certificate = self.find_by serial: serial
    puts "find_public_by_serial"
    puts serial
    puts certificate.content
    puts OpenSSL::X509::Certificate.new(certificate.content).public_key

    return OpenSSL::X509::Certificate.new(certificate.content).public_key
  end
end