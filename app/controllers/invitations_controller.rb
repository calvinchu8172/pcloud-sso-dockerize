class InvitationsController < ApplicationController

	skip_before_filter :verify_authenticity_token
	# before_filter :validate_authentication_token,  :unless => :delete_permission?
	before_filter :validate_cloud_id
	before_filter :validate_device_account, :if => :delete_permission?

	def invitation
		service_logger.note({parameters: params})
		if request.get?
			result = Array.new
			user = User.find_by(email: params[:cloud_id])
			unless user.blank?
				user.invitations.each do |invitation| 
					device = invitation.device
					invitation.accepted_users.each do |accepted_user|
						next unless accepted_user.inbox?(params[:last_updated_at])
						result.push({invitation_key: invitation.key,
							device_id: device.id,
							share_point: invitation.share_point,
							permission: invitation.permission_name,
							accepted_user: accepted_user.user_email,
							accepted_time: accepted_user.accepted_time})
					end
				end 
			end
			result.sort_by! {|inbox_data| -inbox_data[:accepted_time].to_i}
			render :json => result, status: 200
		elsif request.post?
		end
	end


	def permission
		service_logger.note({parameters: params}) 
		# XmppUser.find_by(username: params[:device_account]).session = 1
		if request.post? # API: accepted invitation
			user = User.find_by(email: params[:cloud_id])
			# not decreasing the expire_count when the session queried from redis is not nil
			# API params: 1. cloud_id, 2. invitation_key, 3. authentication_token
			# query from redis, params: 1. invitation_id, 2. user_email
			user = User.find_by(email: params[:cloud_id])
			unless user.blank?
				invitation_session = InvitationSession.create
				data = {user_id: user.id}
				# invitation_session.session.bulk_set(data)
			end
			render :json => {}, status: 200
		elsif request.delete? # API: delete user binding with device, params: 1. device_account, 2. cloud_id
			user = User.find_by(email: params[:cloud_id])
			unless user.blank?
				accepted_users = AcceptedUser.where(user_id: user.id)
				accepted_users.each do |accepted_user|
					xmppp_user = XmppUser.find_by(username: params[:device_account])
					next if xmppp_user.blank?
					if accepted_user.invitation.device.id == xmpp_user.session.to_i
						accepted_user.destroy
					end
				end
				render :json => { "result" => "success" }, status: 200
			end
			# { "result": "success" }, status: 200
			# { "error_code": "004", "invalid device." }, status: 400
			# { "error_code": "012", "invalid cloud id." }, status: 400
			# { "error_code": "013", "invalid certificate." }, status: 400
			# { "error_code": "014", "invalid signature." }, status: 400
		end
	end

	def validate_device_account
		if params[:device_account].blank?
			render :json => { error_code: "004", description: "invalid device." }, status: 400
		end
	end

	def validate_authentication_token
		logger.debug("verify_authentication_token: #{params[:authentication_token]}")
		if params[:authentication_token].blank?
			render :json => { error_code: "012", description: "invalid token." }, status: 400
		end
	end

	def validate_cloud_id
		logger.debug("verify_cloud_id: #{params[:cloud_id]}")
		if params[:cloud_id].blank?	
			render :json => { error_code: "012", description: "invalid cloud id." }, status: 400 
		end
	end

	def delete_permission?
		logger.debug("action_name = #{action_name}, method = #{request.method}")
		action_name == 'permission' && request.delete?
	end

end
