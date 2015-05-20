class PersonalController < ApplicationController
  before_action :authenticate_user!
   before_filter :validate_cloud_id, :only => :device_list

  def index

    @pairing = Pairing.owner.where(user_id: current_user.id)
    service_logger.note({paired_device: @pairing})

    if @pairing.empty?
      @paired = false
      flash[:alert] = flash[:notice] ? flash[:notice] : I18n.t("warnings.no_pairing_device")
      redirect_to "/discoverer/index" and return
    end
  end

  def device_list
    cloud_id = params[ :cloud_id ] || ''
    device_id = ''
    user = User.find_by_encrypted_id( cloud_id )
    @pairing = user.pairings.take(50)
    @accepted_invitations = user.accepted_users.take(50)
    #redis = Redis.new
    result = Array.new
    @redis = Redis.new
   
    @pairing.each do | pairing |
      #info_hash = get_info( pairing )
      device_info = Hash.new
      # redis.HGET  "device:" + pairing.device.id + ":session", "xmpp_account"
      
      device_info[ :xmpp_account ] = @redis.HGET  "device:" + pairing.device.id.to_s + ":session",  "xmpp_account"
      device_info[ :mac_address ] = pairing.device.mac_address.scan(/.{2}/).join(":")
      device_info[ :host_name ] = pairing.device.ddns[ :hostname ] 
      device_info[ :wan_ip ] = pairing.device.ddns[ :ip_address ]
      device_info[ :firmware_ver ] = pairing.device.firmware_version
      device_info[ :last_update_time ] = pairing.device.ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S")
      device_info[ :is_owner ] = true
      device_info[ :encoded_device_id ] = pairing.device.encrypted_id
      result << device_info
      #device_id = device_id + "=>" +info_hash[ :mac_address ].to_s
    end
    
    @accepted_invitations.each do | accepted_invitation |
      #info_hash = get_info( accepted_invitation.invitation )
      device_info = Hash.new
      # redis.HGET  "device:#{pairing.device}:session", "xmpp_account"

      device_info[ :xmpp_account ] = @redis.HGET "device:" + accepted_invitation.invitation.device.id.to_s + ":session", "xmpp_account"
      device_info[ :mac_address ] = accepted_invitation.invitation.device.mac_address.scan(/.{2}/).join(":")
      device_info[ :host_name ] = accepted_invitation.invitation.device.ddns[ :hostname ] 
      device_info[ :wan_ip ] = accepted_invitation.invitation.device.ddns[ :ip_address ]
      device_info[ :firmware_ver ] = accepted_invitation.invitation.device.firmware_version
      device_info[ :last_update_time ] = accepted_invitation.invitation.device.ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S")
      device_info[ :is_owner ] = false
      device_info[ :encoded_device_id ] = accepted_invitation.invitation.device.encrypted_id
      result << device_info
      #device_id = device_id + "=>" +info_hash[ :mac_address ].to_s
    end
      #result.sort{ |a,b| a['is_owner'].to_s == b['is_owner'].to_s ? a['host_name'].to_s <=> b['host_name'].to_s : a['is_owner'].to_s <=> b['is_owner'].to_s }
    result = result.sort{ | a , b | 
      if a[:is_owner] != b[:is_owner]
         a[:is_owner] ? -1 : 1
      else
          a[:host_name] <=> b[:host_name]  
      end
    }
    result_hash = Hash.new
    result.each do |device_info|
      result_hash[ device_info[:encoded_device_id] ] = device_info.except :encoded_device_id
    end
    render :json => result_hash, status: 200
  end

  def profile
    @language = @locale_options.has_value?(current_user.language) ? @locale_options.key(current_user.language) : "English"
  end

  protected
    def get_info(pairing)
      device = pairing.device
      info_hash = Hash.new
      info_hash[:model_class_name] = device.product.model_class_name
      info_hash[:firmware_version] = device.firmware_version
      info_hash[:mac_address] = device.mac_address.scan(/.{2}/).join(":")
      info_hash[:ip] = device.session.hget :ip || device.ddns.get_ip_addr
      if device.ddns
        info_hash[:class_name] = "blue"
        # remove ddns domain name last dot
        info_hash[:title] = device.ddns.hostname + "." + Settings.environments.ddns.chomp('.')
        info_hash[:date] = device.ddns.updated_at.strftime("%Y/%m/%d")
      else
        info_hash[:class_name] = "gray"
        info_hash[:title] = I18n.t("warnings.not_config")
      end
      info_hash
    end

    def validate_cloud_id
      cloud_id = params[:cloud_id]
      user = User.find_by_encrypted_id( cloud_id )
      if user.blank?
        render :json => { error_code: "012", description: "Invalid cloud id or token." }, status: 400
        return
      end
      logger.debug("verify_cloud_id: #{user.id}")
    end

    helper_method :get_info
end
