module InvitationHelper
	
	def check_invitation_available
		cloud_id = current_user[:email] || ''
		@invitation_key = params[:id]

		@invitation = Invitation.find_by(key: @invitation_key)
	    if @invitation.nil?
	      logger.debug('invitation is nil');
	      flash[:alert] = I18n.t("warnings.settings.invitation.not_found")
	      render :template => 'invitations/accept'
	      return
	    end
	    if @invitation.expire_count <= 0
			flash[:alert] = I18n.t("warnings.settings.invitation.counting_expired")
			render :template => '/invitations/accept'
			return 
		end 
	    
		@user = User.find_by(email: cloud_id) 
		@accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)
		unless @accepted_user.blank?
			if @accepted_user.status == 1
				flash[:alert] = I18n.t("warnings.settings.invitation.accepted")
				render :template => '/invitations/accept'
				return 
			end
		end
  	end

	def check_accepted_session
		invitation_key = params[:id]
		invitation = Invitation.find_by(key: invitation_key)
		if invitation.nil?
	      render_error_response "021"
	    end

		@accepted_user = AcceptedUser.find_by(user_id: current_user.id, invitation_id: invitation.id)
		@accepted_session = @accepted_user.session.all
  	end

  	def validate_device_account
		render_error_response "004" if params[:device_account].blank?
	end

	def validate_authentication_token
		render_error_response "012" if params[:authentication_token].blank?
	end

	def validate_cloud_id
		render_error_response "012" if params[:cloud_id].blank?
	end

	def validate_invitation_key
		render_error_response "021" if params[:invitation_key].blank?
	end

	def post_permission?
		action_name == 'permission' && request.post?
	end

	def delete_permission?
		action_name == 'permission' && request.delete?
	end

	def render_success_response
		render :json => { "result" => "success" }, status: 200
	end

	def render_error_response error_code
		error_descriptions = {
			"004" => "invalid device.",
			"012" => "invalid cloud id or token.",
			"013" => "invalid certificate.",
			"014" => "invalid signature.",
			"021" => "invalid invitation key.",
			"022" => "invitation expired."
		}
		render :json => { error_code: error_code, description: error_descriptions[error_code] }, status: 400
	end
end