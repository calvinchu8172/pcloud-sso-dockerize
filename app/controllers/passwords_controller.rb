class PasswordsController < Devise::PasswordsController

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
      email = User.to_adapter.find_first(reset_password_token: reset_pwd_token).email
      email
    end
end