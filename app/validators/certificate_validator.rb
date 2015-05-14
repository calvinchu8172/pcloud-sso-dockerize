class CertificateValidator < ActiveModel::Validator
  def validate(record)

  	key = ""
    options[:signature_key].each {|field| key += record.send(field.to_s)}

    # certificate = OpenSSL::X509::Certificate.new(record.certificate)
    # public_key = OpenSSL::PKey::RSA.new(ENV['AUTH_PUBLIC_KEY'])

    # certificate.verify(public_key)
    # validate_signature(record.certificate, key)
    record.errors["certificaate"] = "invalid certificate" unless record.certificate == "1"
    record.errors["signature"] = "invalid signature" unless record.signature == "1"
  end

   def validate_signature(signature, key)
    sha224 = OpenSSL::Digest::SHA224.new
    signature_inside = sha224.hexdigest(key)

    signature == signature_inside
  end
end