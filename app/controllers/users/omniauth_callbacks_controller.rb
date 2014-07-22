class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    identity = User.from_omniauth(request.env["omniauth.auth"])

    if !identity.user.blank?
      sign_in_and_redirect identity.user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => User::SOCIALS[params[:action].to_sym]) if is_navigational_format?
    else
      session["devise.omniauth_data"] = request.env["omniauth.auth"]
      redirect_to '/oauth/new'
    end
  end

  User::SOCIALS.each do |k, _|
    alias_method k, :all
  end
end