module CheckInvitationKey
  extend ActiveSupport::Concern

  def check_invitation_key_correct

    @user = User.find_by_encoded_id(invitation_params[:cloud_id])
    @invitation= Invitation.find_by(key: invitation_params[:invitation_key])

    if @invitation.nil?
      logger.info("非合法的邀請碼")
      return render :json => { error_code: "021", description: "Invalid invitation key." }, status: 400
    end
  end

  def check_invitation_key_other_features

    @accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)

    if @accepted_user.blank? && @invitation.expire_count <= 0
      logger.info("此邀請已超過可接受的上限次數")
      return render :json => { error_code: "021", description: "Invalid invitation key." }, status: 400
    end

    if @invitation.device.pairing.owner.first.nil?
      logger.info("裝置未配對")
      return render :json => { error_code: "021", description: "Invalid invitation key." }, status: 400
    end

    if @user.id == @invitation.device.pairing.owner.first.user.id
      logger.info("擁有者無法執行此項操作")
      return render :json => { error_code: "021", description: "Invalid invitation key." }, status: 400
    end

    unless @accepted_user.blank?
      if @accepted_user.status == 1
        logger.info("已接受過相同的邀請")
        return render :json => { error_code: "021", description: "Invalid invitation key." }, status: 400
      end
    end

  end

  def check_accepted_session
    @accepted_user = AcceptedUser.find_by(invitation_id: @invitation.id, user_id: @user.id)
    @accepted_session = @accepted_user.session.all
  end

end