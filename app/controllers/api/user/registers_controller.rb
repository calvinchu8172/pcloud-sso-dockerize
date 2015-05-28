<<<<<<< HEAD
class Api::User::RegistersController < Api::Base  
  
  
=======
class Api::User::RegistersController < Api::Base

>>>>>>> feature/register
  def create
    
    @user = Api::User::Register.new valid_params.except(:id)
    @user.email = valid_params[:id]
    @user.agreement = "1"

    unless @user.save

      logger.debug('user errors:' + @user.errors.inspect)

      {"001" => "email",
       "002" => "password",
       "003" => "certificaate",
       "004" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: field + @user.errors[field].first} unless @user.errors[field].empty?}

       return render :json =>  {error_code: '000', description: 'invalid parameters'} unless @user.errors.empty?
    end

    @user.create_token_set

  	render "api/user/tokens/create.json.jbuilder"
  end

  private 
    def valid_params
      params.permit(:id, :password, :certificate_serial, :signature, :app_key, :os)
    end
end
