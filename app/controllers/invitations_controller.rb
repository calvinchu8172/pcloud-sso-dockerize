class InvitationsController < ApplicationController

	skip_before_filter :verify_authenticity_token
	before_filter :verify_authentication_token,  :unless => :delete_permission?
	before_filter :verify_cloud_id

	def invitation
		service_logger.note({parameters: params})
		if request.get?
			result = Array.new
			users = User.where(email: params[:cloud_id])
			users.first.invitations.each do |invitation|
				device = invitation.device
				invitation.accepted_users.each do |accepted_user|
					next unless accepted_user.inbox? params[:last_updated_at]
					result.push({invitation_key: invitation.key,
						device_id: device.id,
						share_point: invitation.share_point,
						permission: invitation.permission_name,
						accepted_user: accepted_user.user_email,
						accepted_time: accepted_user.accepted_time})
				end
			end
			result.sort_by! {|inbox_data| -inbox_data[:accepted_time].to_i}
			render :json => result, status: 200
		elsif request.post?
		end
	end


	def permission
		service_logger.note({parameters: params}) 
		XmppUser.find_by(username: params[:device_account]).session = 1
		if request.post? # API: accepted invitation
		elsif request.delete? # API: delete user binding with device
			# params: 1. device_account, 2. cloud_id
			users = User.where(email: params[:cloud_id])
			user = users.first
			accepted_users = AcceptedUser.where(user_id: user.id)
			accepted_users.each do |accepted_user|
				puts accepted_user
				if accepted_user.invitation.device.id == XmppUser.find_by(username: params[:device_account]).session.to_i
					accepted_user.destroy
					accepted_user.update(:status => 3)
				end
			end
			render :json => { "result" => "success" }, status: 200
			# { "result": "success" }, status: 200
			# { "error_code": "004", "invalid device." }, status: 400
			# { "error_code": "012", "invalid cloud id." }, status: 400
			# { "error_code": "013", "invalid certificate." }, status: 400
			# { "error_code": "014", "invalid signature." }, status: 400
		end
	end

	def verify_authentication_token
		logger.debug("authentication_token = #{params[:authentication_token]}")
		if params[:authentication_token].blank?
			render :json => { error_code: "012", description: "invalid token."}, status: 400
		end
	end

	def verify_cloud_id
		user = User.where(email: params[:cloud_id])
		render :json => { error_code: "012", description: "invalid cloud id."}, status: 400 if user.blank?
	end

	def delete_permission?
		logger.debug("action_name = #{action_name}, method = #{request.method}")
		action_name == 'permission' && request.delete?
	end

end
