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

    # @private
    # for api uses encoded_id.
    #
    # encoded id is the instance id encrypted in AES-256-CBC ({https://github.com/attr-encrypted/encryptor attr-encrypted/encryptor})
    # and then encrypting in Base64 using {#url_safe_encode64 url_safe_encode64} method
    # @note The reason of adding character 'z' at the beginning of return value: <br> NAS will use user's
    #   encoded id (cloud id) as the user account to login the linux system of NAS, and linux doesn't
    #   allow creating an user account starting with numbers, so the solution is adding an character
    #   'z' at the beginning of encoded id, then NAS won't get any cloud id starting with numbers.
    # @example Get encode_id of User instance. (need including Guards::AttrEncryptor in the User model)
    #   user = User.find(1)
    #   puts user.encoded_id #=> "zFjkyW9lxXZvZFEgDVWjcNQ"
    # @see https://github.com/attr-encrypted/encryptor attr-encrypted/encryptor
    # @see #url_safe_encode64 url_safe_encode64 method
    # @return [String] encoded id of the instance
    def encoded_id
      'z'+url_safe_encode64(Encryptor.encrypt(id.to_s, :key => Rails.application.secrets.secret_key_base))
    end


    def url_safe_encode64(str)
      Base64.encode64(str).gsub(/[\s=]+/, "").tr('+/','-_')
    end


    module ClassMethods

      # for api uses encoded_id
      def find_by_encoded_id encoded_id
        begin
          return find(Encryptor.decrypt(url_safe_decode64(encoded_id[1..-1]), :key => Rails.application.secrets.secret_key_base).to_i)
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