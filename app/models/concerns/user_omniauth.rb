module UserOmniauth
  extend ActiveSupport::Concern

  included do

    def changed_password?
      !!self.confirmation_token
    end

    def set_change_password_token
      raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

      self.reset_password_token   = enc
      self.reset_password_sent_at = Time.now.utc
      self.save(validate: false)
      raw
    end

  end
end
