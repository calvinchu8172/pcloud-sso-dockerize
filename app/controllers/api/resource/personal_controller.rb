class Api::Resource::PersonalController < ApplicationController
	before_filter :validate_cloud_id, :only => :device_list
	# def device_list
	#     cloud_id = params[ :cloud_id ] || ''
	#     device_id = ''
	#     user = User.find_by_encrypted_id( cloud_id )
	#     @pairing = user.pairings.take(50)
	#     @accepted_invitations = user.accepted_users.take(50)
	#     result = Array.new
	#     @redis = Redis.new
	   
	#     @pairing.each do | pairing |
	#       device_info = Hash.new
	#       device = pairing.device
	#       ddns = device.ddns
	#       device_info[ :xmpp_account ] = @redis.HGET  "device:" + device.id.to_s + ":session",  "xmpp_account"
	#       device_info[ :mac_address ] = device.mac_address.scan(/.{2}/).join(":")
	#       device_info[ :host_name ] = ddns[ :hostname ] 
	#       device_info[ :wan_ip ] = ddns[ :ip_address ]
	#       device_info[ :firmware_ver ] = device.firmware_version
	#       device_info[ :last_update_time ] = ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S")
	#       device_info[ :is_owner ] = true
	#       device_info[ :encoded_device_id ] = device.encrypted_id
	#       result << device_info
	#     end
	    
	#     @accepted_invitations.each do | accepted_invitation |
	#       device_info = Hash.new
	#       device = accepted_invitation.invitation.device
	#       ddns = device.ddns
	#       device_info[ :xmpp_account ] = @redis.HGET "device:" + device.id.to_s + ":session", "xmpp_account"
	#       device_info[ :mac_address ] = device.mac_address.scan(/.{2}/).join(":")
	#       device_info[ :host_name ] = ddns[ :hostname ] 
	#       device_info[ :wan_ip ] = ddns[ :ip_address ]
	#       device_info[ :firmware_ver ] = device.firmware_version
	#       device_info[ :last_update_time ] = ddns.updated_at.strftime("%Y/%m/%d %H:%I:%S")
	#       device_info[ :is_owner ] = false
	#       device_info[ :encoded_device_id ] = device.encrypted_id
	#       result << device_info
	#     end
	#     result = result.sort{ | a , b | 
	#       if a[:is_owner] != b[:is_owner]
	#          a[:is_owner] ? -1 : 1
	#       else
	#           a[:host_name] <=> b[:host_name]  
	#       end
	#     }
	#     result_hash = Hash.new
	#     result.each do |device_info|
	#       result_hash[ device_info[:encoded_device_id] ] = device_info.except :encoded_device_id
	#     end
	# 	render :json => result_hash, status: 200
	# end

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