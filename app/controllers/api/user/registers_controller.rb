class Api::User::RegistersController < Api::Base  

  def create

    @register = Api::User::Register.new valid_params.except(:id)
    @register.email = valid_params[:id]
    @register.agreement = "1"

    logger.debug "certificate_validator record:" + valid_params.inspect
    unless @register.valid?
      {"001" => "email",
       "002" => "password",
       "003" => "certificaate",
       "004" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @register.errors[field].first} unless @register.errors[field].empty?}
      
      return render :json =>  {error_code: "999", description: @register.errors} unless @register.errors.empty?
    end

    @user.app_info.bulk_set(token_params.slice(:app_key, :os)) if !token_params[:app_key].blank? and !token_params[:os].blank? and ['1', '2'].include?(token_params[:os])
  	render :json => {result: "success"}
  end

  private 
    def valid_params
      params.permit(:id, :password, :certificate, :signature, :app_key, :os)
    end
end
