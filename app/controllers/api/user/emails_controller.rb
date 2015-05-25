class Api::User::EmailsController < Api::Base  
  def update

  	
  	
  	render json: {result: 'success'}
  end

  private 
    def valid_params
      params.permit(:cloud_id, :authentication_token, :new_email)
    end
end
