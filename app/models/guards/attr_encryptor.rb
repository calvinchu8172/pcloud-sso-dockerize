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

    # for api uses encoded_id
    def encoded_id
      url_safe_encode64(Encryptor.encrypt(id.to_s, :key => Rails.application.secrets.secret_key_base))
    end


    def url_safe_encode64(str)
      Base64.encode64(str).gsub(/[\s=]+/, "").tr('+/','-_')
    end


    module ClassMethods

      # for api uses encoded_id
      def find_by_encoded_id encoded_id
        begin
          return find(Encryptor.decrypt(url_safe_decode64(encoded_id), :key => Rails.application.secrets.secret_key_base).to_i)
        rescue
          return nil
        end
      end

      def find_by_encrypted_id encrypt_id
        begin
          return find(Encryptor.decrypt(encrypt_id.unpack('m').first, :key => Rails.application.secrets.secret_key_base).to_i)
        rescue
          return nil
        end
      end

      def url_safe_decode64(str)
        str += '=' * (4 - str.length.modulo(4))
        Base64.decode64(str.tr('-_','+/'))
      end
    end
  end
end