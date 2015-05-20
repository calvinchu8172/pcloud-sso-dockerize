class SslValidator < ActiveModel::Validator

  def validate(record)

    # key = options[:signature_key].inject {|result, element| result += record.send(element.to_s)}
    key = options[:signature_key].map{|field| record.send(field.to_s)}.join('')
    
    record.errors["certificaate"] = key unless verify_certificate(record.certificate) #record.certificate == "1"
    record.errors["signature"] = "invalid signature" unless validate_signature(record.signature, key) #record.signature == "1"
  end

  def validate_signature(signature, key)
    sha224 = OpenSSL::Digest::SHA224.new
    public_key.verify(sha224, signature, key)

    signature == "1"
  end

  private

    def verify_certificate certificate
      begin
        certificate = OpenSSL::X509::Certificate.new(CGI::unescape(certificate))
        return certificate.verify(public_key)
      rescue
        return false
      end
    end  

    def public_key

      return @public_key unless @public_key.blank?

      key_string = ENV['PUBLIC_KEY'] || Settings.environments.public_key
      @public_key = OpenSSL::PKey::RSA.new(key_string)
    end
end