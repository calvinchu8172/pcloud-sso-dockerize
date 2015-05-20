class Api::User::OauthController < Api::Base
  before_action :adjust_provider, only: [:mobile_checkin, :mobile_register]

  # GET /user/1/checkin/:oauth_provider
  def mobile_checkin
    user_id  = checkin_params[:user_id]
    access_token = checkin_params[:access_token]

    data = get_oauth_data(@provider, user_id, access_token)

    @identity = Identity.find_by(uid: user_id, provider: @provider)

    if @data.nil?
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
    user_id  = register_params[:user_id]
    password = register_params[:password]
    access_token = register_params[:access_token]

    @identity = Identity.find_by(uid: user_id, provider: @provider)

    if password.nil? || !password.length.between?(8, 14)
      render :json => { :error_code => '002',  :description => 'Password has to be 8-14 characters length' }, :status => 400
    elsif !@identity.nil?
      render :json => { :error_code => '003',  :description => 'registered account' }, :status => 400
    else
      data = get_oauth_data(@provider, user_id, access_token)
      render :json => { :error_code => '000', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400 if @data.nil?
      identity = Api::User::Oauth.sign_up_oauth_user(user_id, @provider, register_params, data)
      sign_in identity.user
      redirect_to authenticated_root_path
    end

  end

  def get_oauth_data(provider, user_id, access_token)
    begin
      data = RestClient.get('https://www.googleapis.com/oauth2/v2/userinfo', :params => {:access_token => access_token}) if provider == 'google_oauth2'
      data = RestClient.get('https://graph.facebook.com/v2.3/me', :params => {:access_token => access_token}) if provider == 'facebook'
      data = JSON.parse data
    rescue => e
      logger.debug "Invalid oauth token"
      logger.debug e.response
    end

    data if user_id == data["id"]
  end

  private

  def register_params
    params.permit(:user_id, :access_token, :password, :certificate, :signature)
  end

  def checkin_params
    params.permit(:user_id, :access_token)
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
