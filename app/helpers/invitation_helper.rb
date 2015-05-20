module InvitationHelper
	
	def check_invitation_available
		@validation = { :success => false }
		cloud_id = current_user[:email] || ''
		@invitation_key = params[:id] || ''
		@invitation = Invitation.find_by(key: @invitation_key) unless @invitation_key.blank?
	    if @invitation.nil?
	      flash.now[:alert] = I18n.t("warnings.settings.invitation.invalid_key")
	      render :template => '/invitations/accept'
	      return
	    end
	    if @invitation.expire_count <= 0
			flash.now[:alert] = I18n.t("warnings.settings.invitation.counting_expired")
			render :template => '/invitations/accept'
			return 
		end 
		@user = User.find_by(email: cloud_id) 
		@accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)
		unless @accepted_user.blank?
			if @accepted_user.status == 1
				flash.now[:alert] = I18n.t("warnings.settings.invitation.accepted")
				render :template => '/invitations/accept'
				return 
			end
		end
		@validation[:success] = true
  	end

	def check_accepted_session
		invitation_key = params[:id] || ''
		invitation = Invitation.find_by(key: invitation_key) unless invitation_key.blank?
	    render :json => { :key => invitation_key, :status => 'invalid invitation key' } and return if invitation.nil?

		@accepted_user = AcceptedUser.find_by(user_id: current_user.id, invitation_id: invitation.id)
		@accepted_session = @accepted_user.session.all
  	end

	def validate_invitation_params
		if action_name == 'invitation' && request.get?
			render_error_response "012" and return if params[:cloud_id].blank?
			# render_error_response "012" and return if params[:authentication_token].blank?
		end
	end

	def validate_permission_params
		if action_name == 'permission' && request.delete?
			render_error_response "004" and return if params[:device_account].blank?
			render_error_response "012" and return if params[:cloud_id].blank?
			render_error_response "013" and return if params[:certificate].blank? || !verify_certificate(params[:certificate])
			render_error_response "014" and return if params[:signature].blank? || !validate_signature(params[:signature], "#{params[:device_account]}#{params[:cloud_id]}")
		end
	end

	def render_error_response error_code
		error_descriptions = {
			"004" => "invalid device.",
			"012" => "invalid cloud id or token.",
			"013" => "invalid certificate.",
			"014" => "invalid signature."
		}
		render :json => { error_code: error_code, description: error_descriptions[error_code] }, status: 400
	end

	def validate_signature(signature, key)
	    sha224 = OpenSSL::Digest::SHA224.new
	    public_key.verify(sha224, signature, key)
	end

    def verify_certificate certificate
      	begin
        	certificate = OpenSSL::X509::Certificate.new(CGI::unescape(certificate))
        	return certificate.verify(public_key)
      	rescue
        	return false
      	end
    end  

    def public_key
      	return @public_key unless @public_key.blank?
      	key_string = ENV['PUBLIC_KEY'] || Settings.environments.public_key
      	@public_key = OpenSSL::PKey::RSA.new(key_string)
    end
end