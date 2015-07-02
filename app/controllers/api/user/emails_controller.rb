class Api::User::EmailsController < Api::Base 
  before_filter :authenticate_user_by_token_incloud_unconfirmed!, only: :update
  
  def show
    user = Api::User::Email.new(show_params)
    user.valid?
    return render json: Api::User::INVALID_SIGNATURE_ERROR, :status => 400 unless user.errors['signature'].blank?

    render json: user.find_by_cloud_ids.to_json
  end

  def update
    user = Api::User::Email.find_by_encoded_id(valid_params[:cloud_id])
    user.new_email = valid_params[:new_email]
    unless user.update_email
      return render json: user.errors[:email].first, :status => 400 unless user.errors[:email].blank?
    end
    logger.debug("user.errors.to_json: #{user.errors.to_json}")
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
