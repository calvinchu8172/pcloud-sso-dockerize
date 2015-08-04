class ConfirmationsController < Devise::ConfirmationsController

  before_action :user_login!, only: [:edit, :new, :create, :update, :show]
  before_action :email_validate, only: [:update]

  def create
    super
    sign_out(current_user)
  end

  def update
    current_user.skip_reconfirmation!
    current_user.save

    current_user.send_confirmation_instructions
    sign_out(current_user)
    redirect_to hint_confirm_sent_path
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource) unless signed_in?(resource_name)
    hint_signup_path
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

  def email_validate
    new_email = params[:user][:email]
    if current_user.email == new_email
     flash[:alert] = I18n.t("devise.confirmations.same_email_address")
     redirect_to users_confirmation_edit_path
     return
    end

    current_user.email = new_email
    unless current_user.valid?
      flash[:alert] = current_user.errors[:email].first
      redirect_to users_confirmation_edit_path
    end
  end
end
