class Api::User::RegistersController < Api::Base

  def create
    
    @user = Api::User::Register.new valid_params.except(:id)
    @user.email = valid_params[:id]
    @user.agreement = "1"

    logger.debug "certificate_validator record:" + valid_params.inspect

    unless @user.save
      {"001" => "email",
       "002" => "password",
       "003" => "certificaate",
       "004" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @user.errors[field].first} unless @user.errors[field].empty?}
    end

    
    @user.app_info.bulk_set(token_params.slice(:app_key, :os)) if !valid_params[:app_key].blank? and !valid_params[:os].blank? and ['1', '2'].include?(valid_params[:os])
    @user.create_token_set

  	render "api/user/tokens/create.json.jbuilder"
  end

  private 
    def valid_params
      params.permit(:id, :password, :certificate_serial, :signature, :app_key, :os)
    end
end
