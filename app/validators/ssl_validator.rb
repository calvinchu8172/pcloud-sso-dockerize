class SslValidator < ActiveModel::Validator

  def validate(record)
    key = options[:signature_key].map{|field| record.send(field.to_s)}.join('')
    sha224 = OpenSSL::Digest::SHA224.new
    record.errors["signature"] = Api::User::INVALID_SIGNATURE_ERROR unless validate_signature(record.signature, key, record.certificate_serial)
  end

  private

    def validate_signature(signature, key, serial)
      sha224 = OpenSSL::Digest::SHA224.new
      begin
        return Api::Certificate.find_public_by_serial(serial).verify(sha224, Base64.decode64(signature), key)
      rescue
        return false
      end
    end

end