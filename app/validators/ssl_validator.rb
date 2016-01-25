class SslValidator < ActiveModel::Validator

  def validate(record)

    key = options[:signature_key].map{|field| record.send(field.to_s)}.join('')
    sha224 = OpenSSL::Digest::SHA224.new

    puts "***#{record.signature}"
    puts "***#{key}"
    puts "***#{record.certificate_serial}"

    record.errors["signature"] = Api::User::INVALID_SIGNATURE_ERROR unless validate_signature(record.signature, key, record.certificate_serial)
  end



  private

    def validate_signature(signature, key, serial)
      sha224 = OpenSSL::Digest::SHA224.new
      begin
        puts "validate signature in API"
        puts "print all certificate"
        puts Api::Certificate.all.to_json
        puts Api::Certificate.first.serial
        puts Api::Certificate.first.content
        puts "********validate signature in API"
        begin
          puts Api::Certificate.find_public_by_serial(serial).to_s
          a =  Api::Certificate.find_public_by_serial(serial).verify(sha224, Base64.decode64(signature), key)
        rescue Exception => e
          puts e
        end
        puts "$$$#{a.to_s}"
        puts "end of validate signature in API"

        return Api::Certificate.find_public_by_serial(serial).verify(sha224, Base64.decode64(signature), key)
      rescue
        return false
      end
    end

end