module Guards
  module AttrEncryptor

    def self.included(base)
      base.extend(ClassMethods)
    end

    def encrypted_id
      [Encryptor.encrypt(id.to_s, :key => Rails.application.secrets.secret_key_base)].pack('m')
    end

    def escaped_encrypted_id
      CGI::escape(self.encrypted_id)
    end

    module ClassMethods
      def find_by_encrypted_id encrypt_id
        begin
          return find(Encryptor.decrypt(encrypt_id.unpack('m').first, :key => Rails.application.secrets.secret_key_base).to_i)
        rescue
          return nil
        end
      end
    end
  end
end