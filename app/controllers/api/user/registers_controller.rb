class Api::User::RegistersController < Api::Base

  def create
    # 當使用者在 Portal 用 OAuth 註冊過了，再到 APP 上用 Email 註冊時，由於 Portal 的 OAuth 註冊不會設定密碼，
    # 因此沒有密碼可對使用者做驗證，因此須阻擋該流程進行。
    user = Api::User.find_by(email: valid_params[:id])
    return render :json => { error_code: "001", description: "Email has been taken." }, :status => 400 if !user.nil? && user.registered_in_portal_oauth?

    register = Api::User::Register.new valid_params.except(:id)
    register.email = valid_params[:id]
    register.agreement = "1"

    #假如App打api的header有帶Accept-Language的話，就寫入Portal的語系與user的language欄位，與修改瀏覽器的cookies
    #若app註冊時沒有帶accept-language，沒有帶則default的字串會大於5（例如最長的zh-TW字元大小為5），則user寫入內定值'en'
    if !request.headers["Accept-Language"].blank? && request.headers["Accept-Language"].size < 6
      I18n.locale = request.headers["Accept-Language"].to_sym
      register.language = request.headers["Accept-Language"]
      cookies["locale"] = request.headers["Accept-Language"]
    end

    unless register.save
      {"001" => "email",
       "002" => "password"
      }.each { |error_code, field| return render :json => {error_code: error_code, description: field + register.errors[field].first}, :status => 400 unless register.errors[field].empty?}

      return render :json => Api::User::INVALID_SIGNATURE_ERROR, :status => 400 unless register.errors['signature'].empty?
      return render :json =>  {error_code: '000', description: 'invalid parameters'}, :status => 400 unless register.errors.empty?
    end

    logger.debug('register:' + register.attributes.inspect)
    @user = Api::User::Token.new(register.attributes)
    @user.app_key = valid_params[:app_key]
    @user.os = valid_params[:os]
    @user.uuid = valid_params[:uuid]

    logger.debug('create_token:' + @user.attributes.inspect)
    @user.create_token

  	render "api/user/tokens/create.json.jbuilder"

    # api註冊後寫入os及oauth來源資料
    os = LoginLog.check_os(valid_params['os'])
    User.find(register.id).update(os: os, oauth: 'email')

  end

  private
    def valid_params
      params.permit(:id, :password, :certificate_serial, :signature, :app_key, :os, :uuid)
    end
end
