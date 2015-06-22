class Api::User::EmailsController < Api::Base 
  before_filter :authenticate_user_by_token_incloud_unconfirmed!, only: :udpate
  
  def show
    user = Api::User::Email.new(show_params)
    user.valid?
    return render json: Api::User::INVALID_SIGNATURE_ERROR, :status => 400 unless user.errors['signature'].blank?

    render json: user.find_by_cloud_ids.to_json
  end

  def update

    user = Api::User::Email.find_by_encoded_id(valid_params[:cloud_id])
    
    logger.debug('old email:' + user.email)
    user.new_email = valid_params[:new_email]
    logger.debug('after old email:' + user.email)

    unless user.update_email
    	logger.debug('error old email:' + user.email)
      return render json: user.errors[:email].first, :status => 400 unless user.errors[:email].blank?
    end

    
  	logger.debug('update email error:' + user.errors.inspect)

    render json: {result: 'success'}
  end

  private 
    def valid_params
      params.permit(:cloud_id, :authentication_token, :new_email)
    end

    def show_params
      params.permit(:cloud_ids, :certificate_serial, :signature)
    end
end
