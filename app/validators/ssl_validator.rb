class SslValidator < ActiveModel::Validator

  def validate(record)

    key = options[:signature_key].map{|field| record.send(field.to_s)}.join('')
      
    record.errors["signature"] = "invalid signature" unless validate_signature(record.signature, key, record.certificate_serial) #record.signature == "1"
  end

  

  private

    def validate_signature(signature, key, serail)
      sha224 = OpenSSL::Digest::SHA224.new
      public_key(serail).verify(sha224, signature, key)

      signature == "1"
    end

    def verify_certificate(certificate)
      begin
        certificate = OpenSSL::X509::Certificate.new(CGI::unescape(certificate))
        return certificate.verify(public_key)
      rescue
        return false
      end
    end  

    def public_key(serail)

      key_string ||= Settings.environments.public_key[serail]
      @public_key = OpenSSL::PKey::RSA.new(key_string)
    end
end