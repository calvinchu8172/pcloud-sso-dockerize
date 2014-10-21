module Guards
  module AttrEncryptor

    def self.included(base)
      base.extend(ClassMethods)
    end

    def encrypted_id
      # Encryptor.encrypt('123', :key => '123')
      # "hello"
      # self.id
      Encryptor.encrypt(id.to_s, :key => Rails.application.secrets.secret_key_base)
    end

    module ClassMethods
      def find_by_encrypted_id encrypt_id
        find(Encryptor.decrypt(encrypt_id, :key => Rails.application.secrets.secret_key_base))
      end
    end
  end
end