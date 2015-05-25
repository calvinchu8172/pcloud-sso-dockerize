class Api::User::OauthController < Api::Base
  before_action :adjust_provider, only: [:mobile_checkin, :mobile_register]

  # GET /user/1/checkin/:oauth_provider
  def mobile_checkin
    user_id  = checkin_params[:user_id]
    access_token = checkin_params[:access_token]

    data = get_oauth_data(@provider, user_id, access_token)
    return render :json => { :error_code => '000', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400 if data.nil?

    user = User.find_by(email: data['email'])

    return render :json => { :error_code => '001',  :description => 'unregistered' }, :status => 400 if user.nil?

    # 避免來自其他provider的portal user
    return render :json => { :error_code => '002',  :description => 'not binding yet' }, :status => 400 if is_portal_user?(user)

    identity = Identity.find_by(uid: data['id'], provider: @provider)

    if identity.nil?
      identity = Identity.new
      identity.provider = @provider
      identity.user_id = user.id
      identity.uid = data['id']
      identity.save
    end

    return render :json => { :result => 'registered', :account => identity.user.email }, :status => 200

  end

  # POST /user/1/register/:oauth_provider
  def mobile_register
    certificate        = register_params[:certificate]
    user_id            = register_params[:user_id]
    password           = register_params[:password]
    access_token       = register_params[:access_token]

    return render :json => { :error_code => '002',  :description => 'Password has to be 8-14 characters length' }, :status => 400 if password.nil? || !password.length.between?(8, 14)

    data = get_oauth_data(@provider, user_id, access_token)
    return render :json => { :error_code => '001', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400 if data.nil?

    identity = Identity.find_by(uid: data['id'], provider: @provider)
    user = User.find_by(email: data['email'])

    if user.nil?
      user = Api::User::Register.new register_params.except(:access_token, :user_id)
      user.email = data['email']
      user.agreement = "1"
      user.confirmation_token = Devise.friendly_token
      user.confirmed_at = Time.now.utc

      unless user.save
        {"004" => "certificaate",
         "005" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @user.errors[field].first} unless @user.errors[field].empty?}
      end
    end

    return render :json => { :error_code => '003',  :description => 'registered account' }, :status => 400 if identity.present? && !is_portal_user?(user)

    if is_portal_user?(user)
      logger.debug 'portal user'
      user = Api::User::Register.find(user)
      user.confirmation_token = Devise.friendly_token
      user.confirmed_at = Time.now.utc

      unless user.update(register_params.except(:access_token, :user_id))
        {"004" => "certificaate",
         "005" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @user.errors[field].first} unless @user.errors[field].empty?}
       end
    end

    if identity.nil?
      identity = Api::User::Identity.new register_params.except(:access_token, :user_id, :password)
      identity.provider = @provider
      identity.user_id = user.id
      identity.uid = data['id']

      unless identity.save
        {"004" => "certificaate",
         "005" => "signature"}.each { |error_code, field| return render :json =>  {error_code: error_code, description: @user.errors[field].first} unless @user.errors[field].empty?}
      end
    end

    sign_in(:user, user, store: false, bypass: false)
    redirect_to authenticated_root_path

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
      data = nil
    end
  end

  def is_portal_user?(user)
    user.confirmation_token.nil?
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