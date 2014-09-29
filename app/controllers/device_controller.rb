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

  # POST /d/1/register
  def register

    @device = Device.checkin(api_permit)
    xmpp_checkin
    ddns_checkin
    device_session_checkin
    reset 

  	render :json => {:xmpp_account => @account[:name] + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_rescource_id,
                     :xmpp_password => @account[:password],
                     :xmpp_bots => Settings.xmpp.bots}
  end

  private

  def reset
    unless reset_requestment?
      logger.debug("don't reset");
      return
    end

    device_id = @device.id.to_s

    logger.debug("reset reset:" + params[:reset] + ", device id" + device_id)
    pairing = Pairing.find_by_device_id(device_id)
    return if pairing.nil?

    Job::UnpairMessage.new.push_device_id(device_id)
    pairing.disable
  end

  def device_session_checkin
    ip = request.remote_ip
    if(@device.device_session.nil?)
      session = @device.build_device_session(:ip => ip, :xmpp_account => @account[:name], :password => @account[:password])
      session.save
      logger.info('create device session: ' + session.to_json(:except => :password))
    else
      session = @device.device_session.update_attributes(:ip => ip, :password => @account[:password])
      logger.info('update device session new password and ip: ' + ip)
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

    return if !@device.device_session.nil? && @device.device_session.ip == request.remote_ip
    return if reset_requestment?

    ddns = Ddns.find_by_device_id(@device.id)
    return if ddns.nil?
    
    logger.debug('update ddns id:' + ddns.id.to_s)
    job = Job::DdnsMessage.new.push({device_id: @device.id, full_domain: ddns.full_domain})
  end

  def xmpp_checkin

    xmpp_host = Settings.xmpp.server
    admin_username = Settings.xmpp.admin.account
    admin_password = Settings.xmpp.admin.password

    if(@device.device_session.nil?)
      # connect_to_xmpp(admin_username + "@" + xmpp_host, admin_password.to_s)
      @account = {:name => generate_new_username, :password => generate_new_passoword}
      logger.info('create new xmpp account:' + @account[:name])
    else
      # connect_to_xmpp(@device.device_session.xmpp_account + "@" + xmpp_host, @device.device_session.password)
      @account = {:name => @device.device_session.xmpp_account, :password => generate_new_passoword}
      logger.info('change password for account:' + @account[:name])
    end

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
    params.permit(:mac_address, :serial_number, :model_name, :firmware_version);
  end

  def apply_for_xmpp_account
    xmpp_user = XmppUser.find_or_initialize_by(username: @account[:name])
    xmpp_user.password = @account[:password]
    xmpp_user.save
  end

  def apply_new_account

    iq = Jabber::Iq.new(:set)
    iq.id= "a" + generate_new_passoword
    iq.to = Settings.xmpp.server
    iq.from = Settings.xmpp.admin.account + '@' + Settings.xmpp.server
    
    command = Jabber::Command::IqCommand.new('http://jabber.org/protocol/admin#add-user')

    x = Jabber::Dataforms::XData.new(:submit)
    command.add(x)

    form_type_field = Jabber::Dataforms::XDataField.new("FORM_TYPE", :hidden)
    form_type_field.value = 'http://jabber.org/protocol/admin'
    x.add(form_type_field)

    account_field = Jabber::Dataforms::XDataField.new("accountjid", "jid-single")
    account_field.value = @account[:name] + '@' + Settings.xmpp.server
    x.add(account_field)

    passowrd_field = Jabber::Dataforms::XDataField.new("password", "text-private")
    passowrd_field.value = @account[:password]
    x.add(passowrd_field)

    passowrd_verify_field = Jabber::Dataforms::XDataField.new("password-verify", "text-private")
    passowrd_verify_field.value = @account[:password]
    x.add(passowrd_verify_field)

    iq.add(command)
    logger.debug('apply_new_account:' + iq.to_s);
    post_to_xmpp_server iq.to_s
  end

  def apply_new_password

    iq = Jabber::Iq.new(:set)
    iq.id= "a" + generate_new_passoword
    iq.to = Settings.xmpp.server
    iq.from = Settings.xmpp.admin.account + '@' + Settings.xmpp.server

    command = Jabber::Command::IqCommand.new('http://jabber.org/protocol/admin#change-user-password')

    x = Jabber::Dataforms::XData.new(:submit)
    command.add(x)

    form_type_field = Jabber::Dataforms::XDataField.new("FORM_TYPE", :hidden)
    form_type_field.value = 'http://jabber.org/protocol/admin'
    x.add(form_type_field)

    account_field = Jabber::Dataforms::XDataField.new("accountjid", "jid-single")
    account_field.value = @account[:name] + '@' + Settings.xmpp.server
    x.add(account_field)

    passowrd_field = Jabber::Dataforms::XDataField.new("password", "text-private")
    passowrd_field.value = @account[:password]
    x.add(passowrd_field)

    iq.add(command)
    logger.debug('apply_new_password:' + iq.to_s);
    post_to_xmpp_server iq.to_s
  end

  def post_to_xmpp_server(content)
    url = 'http://'  + Settings.xmpp.nodes[0] + ':5280/rest/'
    logger.info('post to: ' + url)
    result = RestClient.post(url, content)
    logger.debug('post to xmpp server result:' + result.to_s);
  end

  def change_xmpp_password
    iq = Jabber::Iq.new(:set)
  end

  # 產生用IP跟MAC 後兩碼的英文字母作為帳號
  def generate_new_username
    'd' + request.remote_ip.gsub('.', '') + "-" + @device.mac_address[-2, 2]
  end

  def generate_new_passoword
    origin = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...10).map { origin[rand(origin.length)] }.join
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
