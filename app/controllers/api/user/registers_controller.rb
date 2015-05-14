class Api::User::RegistersController < Api::Base  

  def create

    @user = Api::User::Register.new valid_params.except(:id)
    @user.email = valid_params[:id]
    @user.agreement = "1"

    logger.debug "certificate_validator record:" + valid_params.inspect
    unless @user.valid?
      {"001" => "email",
       "002" => "password",
       "003" => "certificaate",
       "004" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @user.errors[field].first} unless @user.errors[field].empty?}
    end

  	render "api/user/tokens/create.json.jbuilder"
  end

  private 
    def valid_params
      params.permit(:id, :password, :certificate, :signature, :app_key, :os)
    end
end
