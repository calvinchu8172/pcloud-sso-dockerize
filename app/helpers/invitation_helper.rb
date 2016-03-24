module InvitationHelper

	def check_invitation_available
		@validation = { :success => false, :accepted => false }
		@invitation_key = params[:id] || ''
		@user = current_user
		@invitation = Invitation.find_by(key: @invitation_key) unless @invitation_key.blank?
		@share_point = @invitation.nil? ? "" : @invitation.share_point
	  if @invitation.nil?
	    logger.info("非合法的邀請碼")
	    render :template => '/invitations/accept'
	    return
	  end
	  @accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: current_user.id)
	  if @accepted_user.blank? && @invitation.expire_count <= 0
			logger.info("此邀請已超過可接受的上限次數")
			render :template => '/invitations/accept'
			return
		end
		if @invitation.device.pairing.owner.first.nil?
			logger.info("裝置未配對")
			render :template => '/invitations/accept'
			return
		end
		if current_user.id == @invitation.device.pairing.owner.first.user.id
			logger.info("擁有者無法執行此項操作")
			render :template => '/invitations/accept'
			return
		end
		unless @accepted_user.blank?
			if @accepted_user.status == 1
				logger.info("已接受過相同的邀請")
				@validation[:accepted] = true
				render :template => '/invitations/accept'
				return
			end
		end
		@validation[:success] = true
  end

	def check_accepted_session
		invitation_key = params[:id] || ''
		@invitation = Invitation.find_by(key: invitation_key) unless invitation_key.blank?
	  render :json => { :key => invitation_key, :status => 'invalid invitation key' } and return if @invitation.nil?

		@accepted_user = AcceptedUser.find_by(user_id: current_user.id, invitation_id: @invitation.id)
		@accepted_session = @accepted_user.session.all
 	end

end