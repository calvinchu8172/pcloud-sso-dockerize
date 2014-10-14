# require 'xmpp4r/client'
# require 'xmpp4r'
# require 'xmpp4r/dataforms'
# require 'xmpp4r/command/iq/command'

require 'xmpp4r/client'
require 'xmpp4r/pubsub/iq/pubsub'
require 'xmpp4r/command/iq/command'
require 'xmpp4r/roster/iq/roster'
require 'xmpp4r/discovery/iq/discoitems'
require 'xmpp4r/discovery'
include Jabber

class DeviceController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!
  before_filter :validate_signature, :only => :register
  before_filter :verify_device, :only => :register

  # POST /d/1/register
  def register

    # @device = Device.checkin(api_permit)
    device_checkin
    ddns_checkin
    device_session_checkin
    reset

    xmpp_checkin

  	render :json => {:xmpp_account => @account[:name] + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_resource_id,
                     :xmpp_password => @account[:password],
                     :xmpp_bots => Settings.xmpp.bots,
                     :xmpp_ip_addresses => Settings.xmpp.nodes}
  end

  private

  def device_checkin

    unless api_permit[:firmware_version] == @device.firmware_version
      logger.info('update device from fireware version' + api_permit[:firmware_version] + ' from ' + @device.firmware_version)
      @device.update_attribute(:firmware_version, api_permit[:firmware_version])
    end

  end

  def reset
    unless reset_requestment?
      logger.debug("don't reset");
      return
    end

    device_id = @device.id.to_s

    logger.info("reset reset:" + params[:reset] + ", device id" + device_id)
    pairing = Pairing.find_by_device_id(device_id)
    return if pairing.nil?

    Job::UnpairMessage.new.push_device_id(device_id)
    pairing.destroy
  end

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

    session = {device_id: @device.id, host_name: ddns.hostname, domain_name: Settings.environments.ddns, status: 'start'}
    ddns_session = DdnsSession.create
    job = {:job => 'ddns', :session_id => ddns_session.id}
    ddns.session.bulk_set(session)
    AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message(job.to_json)
  end

  def xmpp_checkin

    @account = Hash.new
    @account[:password] = generate_new_passoword
    @account[:name] = @device.session.fetch :xmpp_account || generate_new_username

    # if(@device.device_session.nil?)
    #   # connect_to_xmpp(admin_username + "@" + xmpp_host, admin_password.to_s)
    #   @account = {:name => generate_new_username, :password => generate_new_passoword}
    #   logger.info('create new xmpp account:' + @account[:name])
    # else
    #   # connect_to_xmpp(@device.device_session.xmpp_account + "@" + xmpp_host, @device.device_session.password)
    #   @account = {:name => @device.device_session.xmpp_account, :password => generate_new_passoword}
    #   logger.info('change password for account:' + @account[:name])
    # end

    logger.info('apply xmpp account:' + @account[:name])
    apply_for_xmpp_account
  end

  def connect_to_xmpp (username, password)

    logger.debug "connect to xmpp user name:" + username + ", password:" + password

    jid = Jabber::JID.new(username)
    @client = Jabber::Client.new(jid)
    @client.connect
    @client.auth(password)
  end

  def api_permit
    params.permit(:mac_address, :serial_number, :model_name, :firmware_version, :signature, :algo);
  end

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

  def generate_new_passoword
    origin = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...10).map { origin[rand(origin.length)] }.join
  end

  def verify_device

    args = api_permit
    result = Device.where( args.slice(:mac_address, :serial_number))

    if result.empty?

      product = Product.where(args.slice(:model_name))
      logger.debug('product search result:' + product.inspect);
      unless product.empty?
        @device = Device.create(args.slice(:mac_address, :serial_number, :firmware_version).merge(product_id: product.first.id))
        logger.info('create new device id:' + @device.id.to_s)
        return 
      end

      logger.info('result: invalid parameter');
      render :json => {:result => 'invalid parameter'}, :status => 400
    else
      @device = result.first
    end
  end

  def validate_signature

  	magic_number = Settings.magic_number
  	mac_address = params[:mac_address] || ''
  	serial_number = params[:serial_number] || ''
  	model_name = params[:model_name] || ''
  	firmware_version = params[:firmware_version] || ''
  	signature = params[:signature] || ''
  	algo = params[:algo]

  	data = mac_address + serial_number.to_s + model_name + firmware_version + magic_number.to_s
    sha224 = OpenSSL::Digest::SHA224.new
    signature_inside = sha224.hexdigest(data)

    logger.debug "signature:" + signature_inside

    unless signature == signature_inside
      # , :signature => signature_inside
	    render :json => {:error => "Failure"}, :status => 400
	  end
  end
end
