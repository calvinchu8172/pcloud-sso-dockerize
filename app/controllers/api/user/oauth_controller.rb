# Oauth API for mobile
# 主要參數如下:
# user_id: oauth provider提供的uuid
# access_token: oauth prodier提供的token
# data: 透過access_token及"get_oauth_data"方法取得使用者資料
# user: identity所綁定的使用者，而且需要注意使用者可變更email
# is_portal_user? : 為portal第一階段未綁定密碼
class Api::User::OauthController < Api::Base
  before_action :adjust_provider, only: [:mobile_checkin, :mobile_register]

  # GET /user/1/checkin/:oauth_provider
  def mobile_checkin
    user_id  = checkin_params[:user_id]
    access_token = checkin_params[:access_token]

    data = get_oauth_data(@provider, user_id, access_token)
    if data.nil? || data['email'].nil?
      logger.debug 'the oauth token is invalid'
      return render :json => { :error_code => '000', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400
    end

    identity = Identity.find_by(uid: data['id'], provider: @provider)
    register = identity.present? ? identity.user : Api::User::OauthUser.find_by(email: data['email'])
    return render :json => { :error_code => '001',  :description => 'unregistered' }, :status => 400 if register.nil?
    return render :json => { :error_code => '002',  :description => 'not binding yet' }, :status => 400 if identity.nil?
    return render :json => { :error_code => '003',  :description => 'not have password' }, :status => 400 if  is_portal_user?(register)

    return render :json => { :result => 'registered', :account => register.email }, :status => 200

  end

  # POST /user/1/register/:oauth_provider
  # 邏輯行為如下:
  # 1. 查詢使用者是否存在，若使用者不存在則直接建立user
  # 2. 承2，若使用者存在則判斷過去是否為portal oauth，若屬portal使用者即更新密碼
  # 3. 最後建立identity並登入
  # signature data: certificate_serial + user_id + access_token
  def mobile_register
    certificate_serial = register_params[:certificate_serial]
    user_id            = register_params[:user_id]
    password           = register_params[:password]
    access_token       = register_params[:access_token]

    return render :json => { :error_code => '002',  :description => 'Password has to be 8-14 characters length' }, :status => 400 if password.nil? || !password.length.between?(8, 14)

    data = get_oauth_data(@provider, user_id, access_token)

    if data.nil? || data['email'].nil?
      logger.debug 'the oauth token is invalid'
      return render :json => { :error_code => '001', :description => "Invalid #{params[:oauth_provider].capitalize} account" }, :status => 400
    end

    identity = Identity.find_by(uid: data['id'], provider: @provider)
    register = identity.present? ? identity.user : Api::User::OauthUser.find_by(email: data['email'])

    # Check the user registered before
    if register.nil?
      register = Api::User::OauthUser.new(register_params)
      register.email = data['email']
      register.agreement = "1"
      register.confirmation_token = Devise.friendly_token
      register.confirmed_at = Time.now.utc

      unless register.save
        logger.debug 'Oauth user not save'
        return render :json => Api::User::INVALID_SIGNATURE_ERROR unless register.errors['signature'].empty?
      end
    end

    if is_portal_user?(register)
      register = Api::User::OauthUser.find(register)
      register.confirmation_token = Devise.friendly_token
      register.confirmed_at = Time.now.utc

      unless register.update(register_params)
        logger.debug 'Oauth portal user not save'
        return render :json => Api::User::INVALID_SIGNATURE_ERROR unless register.errors['signature'].empty?
      end
    else
      return render :json => { :error_code => '003',  :description => 'registered account' }, :status => 400 if identity.present?
    end

    # For varify password
    return render :json => { :error_code => '004', :description => 'Invalid password' }, :status => 400 unless register.valid_password?(password)

    unless identity.present?
      identity = Api::Identity.new(register_params.except(:password, :app_key, :os))
      identity.provider = @provider
      identity["user_id"] = register.id
      identity.uid = data['id']

      unless identity.save
        logger.debug 'Oauth identity not save'
        return render :json => Api::User::INVALID_SIGNATURE_ERROR unless identity.errors['signature'].empty?
      end
    end

    @user = Api::User::Token.new(register.attributes)
    @user.app_key = register_params[:app_key]
    @user.os = register_params[:os]
    @user.create_token

    render "api/user/tokens/create.json.jbuilder"
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
    params.permit(:access_token, :user_id, :password, :certificate_serial, :signature, :app_key, :os)
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
