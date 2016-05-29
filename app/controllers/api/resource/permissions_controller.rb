class Api::Resource::PermissionsController < Api::Base
	include CheckInvitationKey
	skip_before_filter :verify_authenticity_token
	before_filter :validate_delete_permission_params, :only => :destroy
	before_action :check_params, :only => [:show, :create]
	before_action :check_cloud_id, :only => [:show, :create]
	before_action :check_invitation_key_correct, :only => [:show, :create]
  before_action :check_invitation_key_other_features, :only => :create
	before_action :check_signature, :only => [:show, :create]
  before_action :check_accepted_session, :only => :show
  before_action :check_timeout, :only => :show
  before_action :check_error_code, :only => :show

	def show
		begin

			@accepted_user.finish_accept if done?

    rescue Exception => error
    	return render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
		end

		render :json => { result: "success" }, status: 200
	end

	def create
		begin
			@invitation.accepted_by(@user.id) if @accepted_user.blank?

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

    rescue Exception => error
    	return render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
		end

		render :json => { "message" => "Trying to create permission. Now please request the Check Accepting Status API to check if permission is created." }, status: 200
	end

	def destroy
		user = User.find_by_encoded_id(valid_params[:cloud_id])
		return render :json => { error_code: "201", description: "invalid cloud id or token." }, status: 400 if user.blank?
		permissions = Api::Resource::Permission.where(user_id: user.id)
		permissions.each do |permission|
			xmpp_user = XmppUser.find_by(username: valid_params[:device_account])
			next if xmpp_user.blank?
			permission.destroy if permission.invitation.device.id == xmpp_user.session.to_i
		end
		render :json => { "result" => "success" }, status: 200
	end

	def validate_delete_permission_params
		permission = Api::Resource::Permission.new valid_params
	  unless permission.valid?
	  	{ "004" => "device_account",
	  	  "012" => "cloud_id",
	  	  "013" => "certificate_serial",
	  	  "101" => "signature" }.each do |error_code, field|
	  	  	unless permission.errors[field].empty?
	  	  		return render :json =>  { error_code: error_code, description: permission.errors[field].first }, status: 400
	  	  	end
	  	  end
		end
	end

	private

	def valid_params
  	params.permit(:certificate_serial, :signature, :device_account, :cloud_id)
	end

	def invitation_params
		params.permit(:cloud_id, :invitation_key, :certificate_serial, :signature)
	end

	def check_params
    if invitation_params.keys != ["cloud_id", "invitation_key", "certificate_serial", "signature"]
      return render :json => { error_code: "000", description: "Missing required params." }, status: 400
    end
    invitation_params.values.each do |value|
      return render :json => { error_code: "000", description: "Missing required params." }, status: 400 if value.blank?
    end
  end

  def check_cloud_id
    @user = User.find_by_encoded_id(invitation_params[:cloud_id])
    return render :json => { error_code: "201", description: "Invalid cloud id." }, status: 400 if @user.blank?
  end

  def check_signature
    key = invitation_params[:certificate_serial] + invitation_params[:cloud_id] + invitation_params[:invitation_key]
    signature = invitation_params[:signature]
    certificate_serial = valid_params[:certificate_serial]
    return render :json => { error_code: "101", description: "Invalid signature." }, status: 400 unless validate_signature(signature, key, certificate_serial)
  end

  def validate_signature(signature, key, serial)
    sha224 = OpenSSL::Digest::SHA224.new
    begin
      result = Api::Certificate.find_public_by_serial(serial).verify(sha224, Base64.decode64(signature), key)
      return result
    rescue
      return false
    end
  end

  def check_timeout
	  if timeout?
      return render :json => { error_code: "301", description: "Timeout." }, status: 400
	  end
	end

	def timeout?
		expire_in = @accepted_session['expire_at'].to_i - Time.now.to_i
    logger.debug("expire_in: #{expire_in}")
    ( @accepted_session['status'] == 'start' || @accepted_session['status'].nil? ) && expire_in <= 0
	end

  def check_error_code
    if !error_code.blank?
      return render :json => { error_code: "302", description: "Failed on creating permission, error code from NAS: #{error_code}." }, status: 400
    end
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