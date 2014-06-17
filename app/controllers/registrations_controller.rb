require 'net/http'

class RegistrationsController < Devise::RegistrationsController

  # before_filter :check_user_validation, :only=>:create

  def after_inactive_sign_up_path_for(resource)
  	hint_confirm_path
  end

  def getting_started(resource)
    hint_signup_path
  end
  # def check_user_validation
  #    #validate user or redirect with this method
  #    if verify_recaptcha
  # 	  super
  #   else
  #     build_resource(sign_up_params)
  #     clean_up_passwords(resource)
  #     flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."      
  #     flash.delete :recaptcha_error
  #     render :new
  #   end
  # end
  def create
    if verify_recaptcha
  	  super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."
      flash.delete :recaptcha_error
      render :new
    end
  end
  
end
