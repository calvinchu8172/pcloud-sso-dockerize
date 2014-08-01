require 'net/http'

class RegistrationsController < Devise::RegistrationsController

  def update
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)

    # Update user profile when type is profile
    if params[:type] == "profile"
      if account_update_params[:password].blank?
        account_update_params.delete("password")
        account_update_params.delete("password_confirmation")
      end

      # Show error message when display name was blank
      if account_update_params[:display_name].blank?
        resource.errors.add(:display_name, :blank)
        render "edit"
      else
        @user = User.find(current_user.id)
        if @user.update_attributes(account_update_params)
          set_flash_message :notice, :updated
          sign_in @user, :bypass => true
          redirect_to after_update_path_for(@user)
        else
          render "edit"
        end
      end
      

    # Change password when type is password
    elsif params[:type] == "password"
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      if account_update_params[:password].blank? && account_update_params[:password_confirmation].blank?
        resource.errors.add(:password, :blank)
        resource.errors.add(:password_confirmation, :blank)
        resource_updated = false
      else
        resource_updated = update_resource(resource, account_update_params)
      end

      yield resource if block_given?

      if resource_updated
        if is_navigational_format?
          flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
          set_flash_message :notice, flash_key
        end
        sign_in resource_name, resource, bypass: true
        respond_with resource, location: after_update_path_for(resource)
      else
        clean_up_passwords resource
        respond_with resource
      end
    end
  end

  def create
    if verify_recaptcha
  	  super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash.now[:alert] = I18n.t("devise.registrations.captcha")
      flash.delete :recaptcha_error
      render :new
    end
  end
  
  protected
    def after_inactive_sign_up_path_for(resource)
      hint_confirm_path
    end

    def getting_started(resource)
      hint_signup_path
    end

    def after_update_path_for(resource)
      "/personal/profile"
    end
end
