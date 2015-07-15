class ConfirmationsController < Devise::ConfirmationsController

  before_action :user_login!
  before_action :email_already_existed!, only: [:update]

  def new
    get_time_zone
    super
  end

  def update

    if current_user.email == @email
      current_user.send_confirmation_instructions
    else
      current_user.email = @email
      current_user.save
    end

    redirect_to hint_confirm_sent_path
  end

  protected

  def get_time_zone
    time_zone = Time.find_zone(cookies["browser.timezone"])
  end

  def after_confirmation_path_for(resource_name, resource)
    hint_signup_path
    if signed_in?(resource_name)
      hint_signup_path(resource)
    else
      new_session_path(resource_name)
    end
  end

  def after_resending_confirmation_instructions_path_for(resource_name)
    is_navigational_format? ? hint_confirm_sent_path : '/'
  end

  private
  def email_existed?
    !!User.find_by(email: @email)
  end

  def user_login!
    redirect_to unauthenticated_root_path if current_user.nil?
  end

  def email_already_existed!
    @email = params[:user][:email]
    return if current_user.email == @email

    if email_existed?
      flash[:error] = 'Email has been taken.'
      redirect_to users_confirmation_edit_path
    end
  end
end
