# 為負責和 device 溝通的 Restful API
# 主要功能為註冊或者更新device 上的相關資料
# 存取方式的範例 POST mac_address=099789665708&serial_number=A123456&model_name=NSA320S&firmware_version=1.0&algo=1.1&signature=sinature_hash_all_of_parameters_and_magic_number
# 參數說明如下:
# 1. mac_address
# 2. serial_number 該台device的序號，和 mac_address 共同組成唯一的識別方式
# 3. model_name 該台device的產品型號
# 4. firmware_version 該台device目前的軔體版本
# 5. algo 指定 signature 驗證方式
# 6. signature 搭配magic number 作為驗證是否為正確的request 所用
class DeviceController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!
  before_filter :adjust_params, only: :register
  before_filter :validate_device_info, only: :register
  before_filter :validate_signature, :only => :register

  # POST /d/1/register
  # 主要為五個步驟
  # 1. 確認device 軔體版本是否有更新
  # 2. 確認device 的 IP 是否有異動，如IP與前次註冊的不同則更新ddns 上的ip address
  # 3. 更新device session 上 IP 與 XMPP account 相關資料
  # 4. 如request中帶有 reset=1的參數，則重設該台Device
  def register

    service_logger.note({parameters: api_permit})

    @device = Device.checkin api_permit
    ddns_checkin
    install_module
    device_session_checkin
    reset

    xmpp_checkin

    render :json => {:xmpp_account => @account[:name] + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_resource_id,
                     :xmpp_password => @account[:password],
                     :xmpp_bots => Settings.xmpp.bots,
                     :xmpp_ip_addresses => Settings.xmpp.nodes}
  end

  private

  # 如參數帶有reset=1的參數，並且該裝置已配對，則重設該台Device
  def reset
    unless reset_requestment?
      logger.debug("don't reset");
      return
    end

    device_id = @device.id.to_s

    pairing = Pairing.find_by_device_id(device_id)
    return if pairing.nil?

    service_logger.note({'reset' => 'true', device_id: device_id})
    Job::UnpairMessage.new.push_device_id(device_id)
    pairing.destroy
  end

  # 儲存或更新 device 使用的 IP 或 XMPP account
  def device_session_checkin

    @device_session = @device.session.all
    xmpp_account = generate_new_username

    @device.update_ip_list request.remote_ip if request.remote_ip != @device_session['ip']

    if request.remote_ip != @device_session['ip'] || xmpp_account != @device_session['xmpp_account']
      @device_session['ip'] = request.remote_ip
      @device_session['xmpp_account'] = xmpp_account
      @device.session.bulk_set @device_session
      logger.info('create or update device session: ' + @device_session.inspect + ', raw data:' + @device_session.inspect)
    end
  end

  # 記錄下該Device 所需要的modules
  def install_module

    modules = parse_module_list(api_permit[:module]) || Device::DEFAULT_MODULE_LIST
    modules = modules.kind_of?(Array) ? modules : Device::DEFAULT_MODULE_LIST

    @device.module_list.clear
    @device.module_version.clear
    module_version = {}
    modules.each do |item|
     @device.module_list << item[:name].downcase unless item[:name].blank?
     module_version[item[:name].downcase] = item[:ver] unless item[:ver].blank?
    end

    @device.module_version.bulk_set(module_version)
  end

  def parse_module_list module_list
    begin
      modules = JSON.parse(module_list, symbolize_names: true)
    rescue
    end
  end

  def reset_requestment?
    !params[:reset].nil? && params[:reset] == 1.to_s
  end

  # 每次device 登入，會更改DDNS 上的對應IP
  #
  # 以下情況忽略不做 update
  # * 這次登入的IP 跟 上一次的一樣
  # * 當device reset的時候
  # * 該device 還未做過DDNS 註冊
  def ddns_checkin

    device_session = @device.session.all
    return if device_session['ip'] == request.remote_ip
    return if reset_requestment?

    ddns = Ddns.find_by_device_id(@device.id)
    return if ddns.nil?

    logger.debug('update ddns id:' + ddns.id.to_s)
    service_logger.note({'update ddns ip from' => device_session['ip'], 'update fireware to' => request.remote_ip})

    session = {device_id: @device.id, host_name: ddns.hostname, domain_name: Settings.environments.ddns, status: 'start'}
    ddns_session = DdnsSession.create
    job = {:job => 'ddns', :session_id => ddns_session.id}
    ddns_session.session.bulk_set(session)
    AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message(job.to_json)
  end

  # 如果該台 device 沒有xmpp 帳號則註冊一組
  # 如果有，則device 每次連上來都會重設xmpp的帳號
  def xmpp_checkin

    @account = Hash.new
    @account[:password] = generate_new_passoword
    @account[:name] = @device.session.fetch :xmpp_account || generate_new_username

    logger.info('apply xmpp account:' + @account[:name])
    apply_for_xmpp_account
  end

  # 目前只允許下列六項的參數使用
  def api_permit
    params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :module, :algo);
  end

  # 此為直接連線至MongooseIM 的Db 直接存取修改帳XMPP的號密碼
  def apply_for_xmpp_account

    xmpp_user = XmppUser.find_or_initialize_by(username: @account[:name])
    xmpp_user.password = @account[:password]
    xmpp_user.save

    xmpp_user.session = @device.id
  end

  # 用Mac Address 和 序號的英數產生
  def generate_new_username
    'd' + @device.mac_address.gsub(':', '-') + '-' + @device.serial_number.gsub(/([^\w])/, '-')
  end

  #用英數產生密碼，大小寫有別
  def generate_new_passoword
    origin = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...10).map { origin[rand(origin.length)] }.join
  end

  # 使用各個加上magic number的方式驗證 signature 是否正確
  def validate_signature
  	magic_number = Settings.magic_number
  	mac_address = params[:mac_address] || ''
  	serial_number = params[:serial_number] || ''
  	model_class_name = params[:model_class_name] || ''
  	firmware_version = params[:firmware_version] || ''
  	signature = params[:signature] || ''
  	algo = params[:algo]

  	data = mac_address + serial_number.to_s + model_class_name + firmware_version + magic_number.to_s
    sha224 = OpenSSL::Digest::SHA224.new
    signature_inside = sha224.hexdigest(data)

    logger.debug "signature:" + signature_inside

    unless signature == signature_inside
      # , :signature => signature_inside
	    render :json => {:error => "Failure"}, :status => 400
	  end
  end

  # mac address 和 serial number 不得為空值
  # 並且mac address 需符合12個英數的格式
  def validate_device_info
    mac_address_regex = /^[0-9a-f]{12}$/

    mac_address = (params[:mac_address] || '').downcase
    serial_number = params[:serial_number] || ''

    if mac_address_regex.match(mac_address) == nil || serial_number == ''
      logger.info('result: invalid Mac Address or Serial Number');
      render :json => {:result => 'invalid parameter'}, :status => 400
    end
  end

  # 由於 model_name 為 Rails activeModel 中的 method
  # 所以必需於此做轉換，將 model_name 轉為 model_class_name
  def adjust_params
    params[:model_class_name] = params.delete(:model_name)
  end
end
