class Api::Base < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  def authenticate_user_by_token
  	user = Api::User.find(authentication_params[:id])
  	# user.
  end


  def authentication_params
  	params.permit(:user_id, :authentication_token)
  end
end