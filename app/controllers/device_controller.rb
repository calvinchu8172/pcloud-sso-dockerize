# require 'xmpp4r/client'
require 'xmpp4r'

class DeviceController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :validate_signature, :only => :register

  def register

    @device = Device.checkin(api_permit)
    xmpp_checkin
    device_session_checkin
    
  	render :json => {:xmpp_account => @account[:name] + "@" + Settings.xmpp.server + "/" + Settings.xmpp.device_rescource_id,
                     :xmpp_password => @account[:password],
                     :xmpp_bots => Settings.xmpp.bots}
  end

  private

  def device_session_checkin

    if(@device.device_session.nil?)
      @session = @device.build_device_session(:ip => request.remote_ip, :xmpp_account => @account[:name], :password => @account[:password])
      @session.save
    else
      @session = @device.device_session.update_attributes({:ip => request.remote_ip, :password => @account[:password]});
      # @session.ip = request.remote_ip
      # @session.password = @account[:password]
    end
  end

  def xmpp_checkin

    xmpp_host = Settings.xmpp.server
    admin_username = Settings.xmpp.admin.account
    admin_password = Settings.xmpp.admin.password

    if(@device.device_session.nil?)
      connect_to_xmpp(admin_username + "@" + xmpp_host, admin_password.to_s)
      @account = {:name => generate_new_username, :password => generate_new_passoword}
    else
      connect_to_xmpp(@device.device_session.xmpp_account + "@" + xmpp_host, @device.device_session.password)
      @account = {:name => @device.device_session.xmpp_account, :password => generate_new_passoword}
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

    iq = Jabber::Iq.new(:set)
    iq.id = 'change1'
    query = Jabber::IqQuery.new
    query.add_namespace('jabber:iq:register')

    logger.debug "xmpp account username:" + @account[:name] + ", password:" + @account[:password]
    query.add(REXML::Element.new('username').add_text(@account[:name]))
    query.add(REXML::Element.new('password').add_text(@account[:password]))
    iq.add(query)
    @apply_reuslt = @client.send iq
  end

  def change_xmpp_password
    iq = Jabber::Iq.new(:set)
  end

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
