class Api::Resource::PersonalController < Api::Base
	before_filter :authenticate_user_by_token!
	before_filter :validate_cloud_id, :only => :device_list

	def device_list
	  cloud_id = params[ :cloud_id ] || ''
	  device_id = ''
    user = User.includes(pairings: {device: [:product, :ddns]}).find_by_encoded_id( cloud_id )
	  pairings = user.pairings.take(50)
    accepted_invitations = AcceptedUser.includes(invitation: :device).where(user_id: user.id, status: 1).take(50)

    result = Hash.new
    [pairings, accepted_invitations].each do |rel_type|
      rel_type.each  do | type |
        device, is_owner = type.is_a?(Pairing) ? [type.device, true] : [type.invitation.device, false]
        ddns = device.ddns
        result[device.encoded_id] = {
          :xmpp_account => device.get_xmpp_account,
          :mac_address => device.get_mac_address,
          :host_name => ddns.nil? ? '' : ddns[:hostname],
          :wan_ip => ddns.nil? ? '' : ddns.get_ip_addr,
          :firmware_ver => device.firmware_version,
          :model => device.product.model_class_name,
          :last_update_time => ddns.nil? ? '' : ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S"),
          :is_owner => is_owner,
          :online_status => device.online_status,
          :wol_status => device.wol_status,
          :mac_address_of_router_lan_port => device.mac_address_of_router_lan_port
        }
      end
      result.sort_by{ |device_id, obj| [obj[:is_owner] ? 1 : 0,  obj[:host_name]] }
    end
		render :json => result, status: 200
	end

	def validate_cloud_id
    cloud_id = params[:cloud_id]
    user = User.find_by_encoded_id( cloud_id )
    if user.blank?
      render :json => { error_code: "201", description: "Invalid cloud id or token." }, status: 400
      return
    end
  end

end
