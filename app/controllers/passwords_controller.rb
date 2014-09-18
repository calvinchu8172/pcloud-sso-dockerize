class PasswordsController < Devise::PasswordsController

  def create
    # Cannot reset password when user was login with oauth
    if omniauth_accout?(params[:user][:email])
      self.resource = User.find_by_email(params[:user][:email])
      yield resource if block_given?
      resource.errors.add(:email, :not_found)
      render "new"
    else
      super
    end
  end

  def edit
    super
    @email = get_user_email_by_password_token(params[:reset_password_token])
  end

  def update
    @email = get_user_email_by_password_token(params[:user][:reset_password_token])
    super
  end

  protected
    def after_sending_reset_password_instructions_path_for(resource_name)
      hint_sent_path
    end

    def after_resetting_password_path_for(resource)
      hint_reset_path
    end

  private
    def get_user_email_by_password_token(password_token)
      reset_pwd_token = Devise.token_generator.digest(self, :reset_password_token, password_token)
      user = User.to_adapter.find_first(reset_password_token: reset_pwd_token)
      if user.nil?
        redirect_to new_session_path(resource_name)
      else
        user.email
      end
    end

    def omniauth_accout?(user_email)
      oauth = false
      user = User.find_by_email(user_email)
      if !user.nil?
        user.identity.each do |auth|
          oauth = true if user.created_at <= auth.created_at
        end
      end
      oauth
    end
end