class Api::User::RegistersController < Api::Base  
  
  
  def create

  	render :json => {}
  end

  private 
    def valid_params
      params.permit(:id, :password, :certificate, :signature, :app_key, :os)
    end
end
