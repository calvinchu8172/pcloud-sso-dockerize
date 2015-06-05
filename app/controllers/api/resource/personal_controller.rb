class Api::Resource::PersonalController < Api::Base
	before_filter :authenticate_user_by_token!
	before_filter :validate_cloud_id, :only => :device_list

	def device_list
	  cloud_id = params[ :cloud_id ] || ''
	  device_id = ''
	  user = User.find_by_encrypted_id( cloud_id )
	  pairings = user.pairings.take(50)
	  accepted_invitations = AcceptedUser.where(user_id: user.id, status: 1).take(50)
	  redis = Redis.new

	  own_device = Hash.new
	  pairings.each do | pairing |
	    device = pairing.device
	    ddns = device.ddns
	    own_device[device.encrypted_id] = {
	    	:xmpp_account => (redis.HGET "device:#{device.id.to_s}:session", "xmpp_account"),
	     	:mac_address => device.mac_address.scan(/.{2}/).join(":"),
	     	:host_name => ddns[ :hostname ],
	     	:wan_ip => ddns[ :ip_address ],
	     	:firmware_ver => device.firmware_version,
	     	:last_update_time => ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S"),
	     	:is_owner => true
	    }
    end
	  own_device.sort_by{ |device_id, obj| obj[:host_name] }

	  others_device = Hash.new
	  accepted_invitations.each do | accepted_invitation |
	    device_info = Hash.new
      device = accepted_invitation.invitation.device
      ddns = device.ddns
	    others_device[device.encrypted_id] = {
		    :xmpp_account => (redis.HGET "device:#{device.id.to_s}:session", "xmpp_account"),
		    :mac_address => device.mac_address.scan(/.{2}/).join(":"),
		    :host_name => ddns[ :hostname ],
		    :wan_ip => ddns[ :ip_address ],
		    :firmware_ver => device.firmware_version,
		    :last_update_time => ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S"),
		    :is_owner => false
	    }
	  end
		others_device.sort_by{ |device_id, obj| obj[:host_name] }

		result_hash = own_device.merge(others_device);
		render :json => result_hash, status: 200
	end

	def validate_cloud_id
    cloud_id = params[:cloud_id]
    user = User.find_by_encrypted_id( cloud_id )
    if user.blank?
      render :json => { error_code: "012", description: "Invalid cloud id or token." }, status: 400
      return
    end
  end

end