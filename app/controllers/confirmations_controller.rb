class ConfirmationsController < Devise::ConfirmationsController

  layout 'rwd'

  before_action :user_login!, only: [:edit, :new, :create, :update]
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

  def show # overridden
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      redirect_to unauthenticated_root_path
      # respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    sign_out(current_user) if current_user
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
