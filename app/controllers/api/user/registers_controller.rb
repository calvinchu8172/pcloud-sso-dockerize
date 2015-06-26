class Api::User::RegistersController < Api::Base

  def create

    register = Api::User::Register.new valid_params.except(:id)
    register.email = valid_params[:id]
    register.agreement = "1"

    unless register.save

      {"001" => "email",
       "002" => "password"
      }.each { |error_code, field| return render :json =>  {error_code: error_code, description: field + register.errors[field].first}, :status => 400 unless register.errors[field].empty?}

       return render :json => Api::User::INVALID_SIGNATURE_ERROR, :status => 400 unless register.errors['signature'].empty?
       return render :json =>  {error_code: '000', description: 'invalid parameters'}, :status => 400 unless register.errors.empty?
    end

    logger.debug('register:' + register.attributes.inspect)
    @user = Api::User::Token.new(register.attributes)
    @user.app_key = valid_params[:app_key]
    @user.os = valid_params[:os]

    logger.debug('create_token:' + @user.attributes.inspect)
    @user.create_token

  	render "api/user/tokens/create.json.jbuilder"
  end

  private
    def valid_params
      params.permit(:id, :password, :certificate_serial, :signature, :app_key, :os)
    end
end
