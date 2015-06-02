class Api::User::EmailsController < Api::Base 
  before_filter :authenticate_user_by_token!
   
  def update

    user = Api::User::Email.find_by_encoded_id(valid_params[:cloud_id])
    
    logger.debug('old email:' + user.email)
    user.new_email = valid_params[:new_email]
    logger.debug('after old email:' + user.email)

    unless user.update_email
    	logger.debug('error old email:' + user.email)
      return render json: user.errors[:email].first unless user.errors[:email].blank?
    end

    
  	logger.debug('update email error:' + user.errors.inspect)

    render json: {result: 'success'}
  end

  private 
    def valid_params
      params.permit(:cloud_id, :authentication_token, :new_email)
    end
end
