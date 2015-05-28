class SslValidator < ActiveModel::Validator

  def validate(record)

    key = options[:signature_key].map{|field| record.send(field.to_s)}.join('')
      
    record.errors["signature"] = "invalid signature" unless validate_signature(record.signature, key, record.certificate_serial) #record.signature == "1"
  end

  

  private

    def validate_signature(signature, key, serail)

      return signature == "1"

      sha224 = OpenSSL::Digest::SHA224.new
      begin
        return Api::Certificate.find_public_by_serial(serail).verify(sha224, signature, key)
      rescue
        return false
      end    
    end
    
end