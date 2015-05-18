class Api::User::OauthController < Api::Base
  skip_before_filter :verify_authenticity_token, :only => :mobile_register
  before_action :adjust_provider, only: [:mobile_checkin, :mobile_register]

  # GET /user/1/checkin/:oauth_provider
  def mobile_checkin
    user_id  = params[:user_id]

    @user = Identity.find_by(uid: user_id, provider: @provider)

    if @user.nil?
      render :json => { :error_code => '001',  :description => 'unregistered' }, :status => 400
    elsif @user.user.confirmation_token.nil?
      render :json => { :error_code => '002',  :description => 'not binding yet' }, :status => 400
    else
      render :json => { :result => 'registered', :account => @user.user.email }, :status => 200
    end
  end

  # POST /user/1/register/:oauth_provider
  def mobile_register
    user_id      = params[:user_id]
    access_token = params[:access_token]
    password     = params[:password]

    @user = Identity.find_by(uid: user_id, provider: @provider)

    if password.nil? || !password.length.between?(8, 14)
      render :json => { :error_code => '002',  :description => 'Password has to be 8-14 characters length' }, :status => 400
    elsif !@user.nil?
      render :json => { :error_code => '003',  :description => 'registered account' }, :status => 400
    else
      data = get_oauth_data(@provider, access_token)
      identity = User.sign_up_oauth_user(user_id, @provider, password, data)
      sign_in identity.user
      redirect_to authenticated_root_path
    end

  end

  private
  def adjust_provider
    if !['google', 'facebook'].include?(params[:oauth_provider])
      render :file => 'public/404.html', :status => :not_found, :layout => false
    else
      # Rewrite params for follow ominiauth rule.
      @provider = 'google_oauth2' if params[:oauth_provider] == 'google'

      @provider = @provider || params[:oauth_provider]
    end
  end

  def get_oauth_data(provider, access_token)
    begin
      data = RestClient.get('https://www.googleapis.com/oauth2/v1/userinfo', :params => {:access_token => access_token}) if provider == 'google_oauth2'
      data = RestClient.get('https://graph.facebook.com/v2.3/me', :params => {:access_token => access_token}) if provider == 'facebook'
      data = JSON.parse data
      data
    rescue Exception => e
      logger.debug "Invalid oauth token"
      logger.debug e.response
      render :json => { :error_code => '001', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400
    end
  end

end
