class Api::User::Oauth < Api::User::Register

  def self.sign_up_oauth_user(user_id, provider, password, data)
    identity = Identity.where(provider: provider, uid: user_id ).first_or_initialize

    if identity.user.blank?
      user = User.where('email = ?', data["email"]).first
      if user.blank?
        user = User.new
        user.skip_confirmation!
        user.password = password
        user.fetch_details_from_oauth(data)
        user.edm_accept = 0
        user.agreement = "1"
        user.save!
      end
      identity.user = user
      identity.save!
    end
    identity
  end

end