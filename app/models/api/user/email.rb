class Api::User::Email < Api::User
  attr_accessor :new_email
  
  def update_email
    return false if new_email_not_modified? or new_email_not_uniqueness?
    self.update_without_password(email: new_email)
  end

  private
    def new_email_not_modified?
      if new_email == email
        errors.add(:email, {error_code: '003', description: 'new E-mail is the same as old'})
      end
    end

    def new_email_not_uniqueness?
      errors.add(:email, {error_code: '002', description: 'new E-mail has been taken'}) if User.find_by email: new_email
    end  
end