class Api::User::OauthController < Api::Base
  before_action :adjust_provider, only: [:mobile_checkin, :mobile_register]

  # GET /user/1/checkin/:oauth_provider
  def mobile_checkin
    user_id  = checkin_params[:user_id]
    access_token = checkin_params[:access_token]

    data = get_oauth_data(@provider, user_id, access_token)

    @identity = Identity.find_by(uid: user_id, provider: @provider)

    if data.nil?
      render :json => { :error_code => '000', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400
    elsif @identity.nil?
      render :json => { :error_code => '001',  :description => 'unregistered' }, :status => 400
    elsif @identity.user.confirmation_token.nil?
      render :json => { :error_code => '002',  :description => 'not binding yet' }, :status => 400
    else
      render :json => { :result => 'registered', :account => @identity.user.email }, :status => 200
    end
  end

  # POST /user/1/register/:oauth_provider
  def mobile_register
    certificate = register_params[:certificate]
    user_id            = register_params[:user_id]
    password           = register_params[:password]
    access_token       = register_params[:access_token]

    @identity = Identity.find_by(uid: user_id, provider: @provider)

    if password.nil? || !password.length.between?(8, 14)
      render :json => { :error_code => '002',  :description => 'Password has to be 8-14 characters length' }, :status => 400
    elsif !@identity.nil?
      render :json => { :error_code => '003',  :description => 'registered account' }, :status => 400
    else
      data = get_oauth_data(@provider, user_id, access_token)
      if data.nil?
        render :json => { :error_code => '000', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400
      else
        @user = Api::User::Register.new register_params.except(:access_token, :user_id)
        @user.email = data['email']
        @user.agreement = "1"

        logger.debug "certificate_validator record:" + register_params.inspect

        unless @user.save
          {"004" => "certificaate",
           "004" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @user.errors[field].first} unless @user.errors[field].empty?}
        end

        sign_in(:user, @user, store: false, bypass: false)
      end
    end

  end


  def get_oauth_data(provider, user_id, access_token)
    begin
      data = RestClient.get('https://www.googleapis.com/oauth2/v1/userinfo', :params => {:access_token => access_token}) if provider == 'google_oauth2'
      data = RestClient.get('https://graph.facebook.com/v2.3/me', :params => {:access_token => access_token}) if provider == 'facebook'
      data = JSON.parse data
      data
    rescue Exception => e
      logger.debug "Invalid oauth token"
      logger.debug e.response
    end
    data if user_id = data["id"]
  end

  private

  def register_params
    params.permit(:access_token, :user_id, :password, :certificate, :signature)
  end

  def checkin_params
    params.permit(:access_token, :user_id)
  end

  def adjust_provider
    if !['google', 'facebook'].include?(params[:oauth_provider])
      render :file => 'public/404.html', :status => :not_found, :layout => false
    else
      @provider = 'google_oauth2' if params[:oauth_provider] == 'google'

      @provider ||=  params[:oauth_provider]
    end
  end


end
