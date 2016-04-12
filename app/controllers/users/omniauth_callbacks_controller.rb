class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    # binding.pry
    oauth_data      = filter_data(request.env["omniauth.auth"])
    identity        = User.from_omniauth(oauth_data)
    session[:oauth] = identity.provider

    if !identity.user.blank?

      unless identity.user.changed_password?
        change_password_token = identity.user.set_change_password_token
        title = "bind_account"
        redirect_to edit_password_url(identity.user, reset_password_token: change_password_token, title: title)
      else
        #記錄user註冊的os與oauth
        oauth = identity.provider
        identity.user.update(os: 'web', oauth: oauth) if identity.user.os.nil? || identity.user.oauth.nil?
        #記錄user登入的歷程
        user = identity.user
        user_id = user.id
        sign_in_at = Time.now
        sign_out_at = nil
        sign_in_fail_at = nil
        sign_in_ip = user.current_sign_in_ip
        os = 'web'
        LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)

        set_flash_message(:notice, :success, :kind => User::SOCIALS[params[:action].to_sym]) if is_navigational_format?

        sign_in_and_redirect identity.user, :event => :authentication #this will throw if @user is not activated
      end
    else
      session["devise.omniauth_data"] = oauth_data
      redirect_to '/oauth/new'
    end
  end

  User::SOCIALS.each do |k, _|
    alias_method k, :all
  end

  private

    def filter_data(auth)
      # which key was your want to keep
      key_list = ["provider",
                  "uid",
                  "credentials",
                  "token",
                  "expires_at",
                  "expires",
                  "first_name",
                  "last_name",
                  "name",
                  "email",
                  "middle_name",
                  "locale",
                  "gender"]

      auth.each_pair do |key, value|
        if value.is_a?(Hash)
          filter_data(value)
        else
          auth.delete(key) if !key_list.include?(key)
        end
      end
      auth
    end
end