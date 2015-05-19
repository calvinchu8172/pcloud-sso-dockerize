class InvitationsController < ApplicationController
	include InvitationHelper
	skip_before_filter :verify_authenticity_token
	before_filter :store_location
	before_filter :authenticate_user!, :only => [:accept]
	
	# before_filter :validate_authentication_token,  :unless => :delete_permission? # called by device
	before_filter :validate_device_account, :if => :delete_permission?

	# for invitation accepting flow
	before_filter :check_invitation_available, :only => [:accept]
	before_filter :check_accepted_session, :only => [:check_connection]
	
	def accept
		@invitation.accepted_by(@user.id) if @accepted_user.blank?
		connect_to_device
	end

	def invitation # API: get invitation key list
		service_logger.note({ parameters: params })
		if request.get?
			last_updated_at = params[:last_updated_at].to_i
			result = Array.new
			user = User.find_by_encrypted_id(params[:cloud_id])
			render_error_response "012" if user.blank?
			user.invitations.each do |invitation| 
				device = invitation.device
				invitation.accepted_users.each do |accepted_user|
					next unless accepted_user.inbox?(last_updated_at)
					result.push({ invitation_key: invitation.key,
						device_id: device.id,
						share_point: invitation.share_point,
						permission: invitation.permission_name,
						accepted_user: accepted_user.user_email,
						accepted_time: accepted_user.accepted_time })
				end
			end 
			result.sort_by! { |data| -Time.parse(data[:accepted_time]).to_i }
			render :json => result, status: 200
		elsif request.post?
		end
	end

	def permission
		service_logger.note({ parameters: params }) 
		invitation_key = params[:invitation_key] || ''
		device_account = params[:device_account] || ''
		if request.delete? # API: delete user binding with device
			user = User.find_by_encrypted_id(params[:cloud_id])
			render_error_response "012" if user.blank?

			accepted_users = AcceptedUser.where(user_id: user.id)
			render_success_response if accepted_users.blank?
			accepted_users.each do |accepted_user|
				xmpp_user = XmppUser.find_by(username: device_account)
				next if xmpp_user.blank?
				if accepted_user.invitation.device.id == xmpp_user.session.to_i
					accepted_user.destroy
				end
			end
			render_success_response
		end
	end

	def connect_to_device
	    waiting_expire_at = (Time.now() + AcceptedUser::WAITING_PERIOD).to_i
	    job_params = { 
	      device_id: @invitation.device.id, 
	      share_point: @invitation.share_point, 
	      permission: @invitation.permission_name, 
	      expire_at: waiting_expire_at,
	      status: :start 
	    }
	    @accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)
	    @accepted_user.session.bulk_set(job_params)   
	    @accepted_session = @accepted_user.session.all
		@accepted_session[:expire_in] = AcceptedUser::WAITING_PERIOD.to_i

		# AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message('{ "job":"create_permission", "invitation_id":"' + @invitation.id.to_s + '", "user_email":"' + @user.email + '" }')
		
		logger.info("connect to device session:" + @accepted_session.inspect)
	end
	
	def check_connection
		check_timeout
		# set the status of accepted user to 1:success
		AcceptedUser.update(@accepted_user.id, :status => 1) if @accepted_session['status'] == 'done'
		result = { :status => @accepted_session['status'], :expire_at => @accepted_session['expire_at'] }
		render :json => result
  	end

	def check_timeout
	    expire_in = @accepted_user.session_expire_in.to_i
	    logger.debug("expire_in: #{expire_in}")
	    if(@accepted_session['status'] == 'start' && expire_in <= 0)
	      @accepted_user.session.store('status', :timeout)
	      @accepted_session['status'] = :timeout
	    end
	end

end
