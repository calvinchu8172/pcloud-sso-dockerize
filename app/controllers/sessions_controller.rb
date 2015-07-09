class SessionsController < Devise::SessionsController

  # POST /resource/sign_in
  def create
    if omniauth_accout?(params[:user][:email])
      self.resource = resource_class.new(sign_in_params)
      flash[:alert] = I18n.t("devise.failure.already_oauth_account")
      redirect_to action: 'new'
    else
      super
    end
  end

  private
  def omniauth_accout?(user_email)
    oauth = false
    user = User.find_by_email(user_email)
    if !user.nil?
      oauth = true if user.confirmation_token.nil?
    end
    oauth
  end

end