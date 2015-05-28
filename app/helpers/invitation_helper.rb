module InvitationHelper

	def check_invitation_available
		@validation = { :success => false }
		cloud_id = current_user[:email] || ''
		@invitation_key = params[:id] || ''
		@invitation = Invitation.find_by(key: @invitation_key) unless @invitation_key.blank?
	  if @invitation.nil?
	    logger.info(I18n.t("warnings.settings.invitation.invalid_key"))
	    render :template => '/invitations/accept'
	    return
	  end
	  if @invitation.expire_count <= 0
			logger.info(I18n.t("warnings.settings.invitation.counting_expired"))
			render :template => '/invitations/accept'
			return
		end
		@user = User.find_by(email: cloud_id)
		if @user.id == @invitation.device.pairing.first.user.id
			logger.info(I18n.t("warnings.settings.invitation.accepting_by_owner")) #shouldn't accepted by owner
			render :template => '/invitations/accept'
		end
		@accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)
		unless @accepted_user.blank?
			if @accepted_user.status == 1
				logger.info(I18n.t("warnings.settings.invitation.accepted"))
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

end