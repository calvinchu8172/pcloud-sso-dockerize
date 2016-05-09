# 被分享者接受邀請的流程如下
# * start: 接受邀請流程的起始狀態，並會發送 start message 給device
# * success: 接受邀請成功
# * failure: 在start之後，若bot與device的溝通狀況出現問題，則判斷為failure
# * timeout: 在start之後，使用者在一定的時間後仍無法成功接受邀請，則判斷為timout
class InvitationsController < ApplicationController
	include InvitationHelper
	before_filter :store_location, :only => [:accept]
	before_filter :authenticate_user!, :only => [:accept]
	before_filter :check_invitation_available, :only => [:accept]
	before_filter :check_accepted_session, :only => [:check_connection]

	def accept
		@invitation.accepted_by(@user.id) if @accepted_user.blank?
		connect_to_device
	end

	def connect_to_device
	  waiting_expire_at = (Time.now() + AcceptedUser::WAITING_PERIOD).to_i
	  job_params = {
	    device_id: @invitation.device.id,
	    share_point: @invitation.share_point,
	    permission: @invitation.permission_name,
	    cloud_id: @user.encoded_id,
	    expire_at: waiting_expire_at,
	    status: :start
	  }
	  @accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)
	  @accepted_user.session.bulk_set(job_params)
    @accepted_user.session.expire((AcceptedUser::WAITING_PERIOD + 0.2.minutes).to_i)

    @accepted_session = job_params
		@accepted_session[:expire_in] = AcceptedUser::WAITING_PERIOD.to_i

		job = {:job => 'create_permission', :session_id => @accepted_user.id.to_s}
		AwsService.send_message_to_queue(job)
	end

	def check_connection
		check_timeout

		# update the status of accepted_user from 0 to 1
		@accepted_user.finish_accept if done?
		result = { :status => session_status, :expire_at => @accepted_session['expire_at'] }
		result.store(:error_code, error_code) unless error_code.blank?
		render :json => result
  end

	def check_timeout
	  expire_in = @accepted_user.session_expire_in.to_i
	  logger.debug("expire_in: #{expire_in}")
	  if timeout?
	    @accepted_user.session.store('status', :timeout)
	    @accepted_session['status'] = :timeout
	  end
	end

	private
	def timeout?
		expire_in = @accepted_user.session_expire_in.to_i
		@accepted_session['status'] == 'start' && expire_in <= 0
	end

	def done?
		@accepted_session['status'] == 'done'
	end

	def session_status
		@accepted_session['status']
	end

	def error_code
		@accepted_session['error_code']
	end

end
