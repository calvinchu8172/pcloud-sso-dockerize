class Api::User::Email < Api::User
  attr_accessor :new_email, :cloud_ids, :certificate_serial, :signature
  validates_with SslValidator, signature_key: [:certificate_serial, :cloud_ids]

  def update_email
    return false if new_email_not_modified? or new_email_not_uniqueness?
    update_without_password(email: new_email)
  end

  def find_by_cloud_ids
    encoded_ids = @cloud_ids.split(',')
    result = {emails: {}, ids_not_found: []}
    encoded_ids.each do |encoded_id|
      record = Api::User.find_by_encoded_id(encoded_id)
      if record.nil?
        result[:ids_not_found] << encoded_id
      else
        result[:emails][encoded_id] = record.email
      end
    end

    result
  end

  def update_without_password(params={})
      params.delete(:password)
      params.delete(:password_confirmation)

      self.email = params.delete(:email)
      return false if new_email_not_valid?

      self.save(:validate => false)
      clean_up_passwords
      return true
  end

  private
    def new_email_not_valid?
      self.valid?
      errors.set(:email, [{error_code: '004', description: 'invalid email'}]) unless self.errors[:email].blank?
    end

    def new_email_not_modified?
      if new_email == email
        errors.add(:email, {error_code: '003', description: 'new E-mail is the same as old'})
      end
    end

    def new_email_not_uniqueness?
      errors.add(:email, {error_code: '002', description: 'new E-mail has been taken'}) if User.find_by email: new_email
    end  
end