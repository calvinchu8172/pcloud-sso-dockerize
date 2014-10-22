module PairingHelper

  def check_device_available

    @device = Device.find_by_encrypted_id(URI.decode(params[:id]))
    if @device.nil?
      # Device is not found
      logger.debug('device is nil');
      flash[:alert] = I18n.t("warnings.settings.pairing.not_found")
      redirect_to controller: "discoverer", action: "index"
      return
    elsif !@device.pairing.owner.empty?
      # device is paired already
      flash[:alert] = I18n.t("warnings.settings.pairing.pair_already")
      redirect_to controller: "discoverer", action: "index"
      return 
    end

    @pairing_session = @device.pairing_session.all

    if handling?(@device.id, current_user.id)
      # Device is pairing
      flash[:alert] = I18n.t("warnings.settings.pairing.in_pairing")
      redirect_to controller: "discoverer", action: "index"
    end
  end

  def check_pairing_session

    @device = Device.find_by_encrypted_id params[:id]
    if @device.nil?
      render :json => {:id => @device.id, :status => 'not registered device'}
    end

    @pairing_session = @device.pairing_session.all

    if handling?(@device.id, current_user.id)
      render :json => {:id => @device.id, :status => 'device is pairing'}
    end
  end

  def handling?(device_id, user_id)
    !@pairing_session.empty? && @pairing_session['user_id'] != current_user.id.to_s && Device.handling_status.include?(@pairing_session['status'])
  end

end
