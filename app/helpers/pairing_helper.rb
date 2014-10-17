module PairingHelper

  def check_device_available
    device_id = params[:id]

    if !device_registered?(device_id)
      # Device is not found
      flash[:alert] = I18n.t("warnings.settings.pairing.not_found")
      redirect_to controller: "discoverer", action: "index"
    elsif paired?(device_id)
      # device is paired already
      flash[:alert] = I18n.t("warnings.settings.pairing.pair_already")
      redirect_to controller: "discoverer", action: "index"
    end

    @device = Device.find device_id
    @pairing_session = @device.pairing_session.all

    if handling?(@device.id, current_user.id)
      # Device is pairing
      flash[:alert] = I18n.t("warnings.settings.pairing.in_pairing")
      redirect_to controller: "discoverer", action: "index"
    end
  end

  def check_pairing_session
    device_id = params[:id]

    if !device_registered?(device_id)
      render :json => {:id => device_id, :status => 'not registered device'}
    # elsif paired?(device_id)
    #   render :json => {:id => device_id, :status => 'device is paired'}
    end

    @device = Device.find(device_id)
    @pairing_session = @device.pairing_session.all

    if handling?(@device.id, current_user.id)
      render :json => {:id => device_id, :status => 'device is pairing'}
    end
  end

  def device_registered?(device_id)
    Device.exists? device_id
  end

  def handling?(device_id, user_id)
    !@pairing_session.empty? && @pairing_session['user_id'] != current_user.id.to_s && Device.handling_status.include?(@pairing_session['status'])
  end

  def paired?(device_id)
    Pairing.owner.exists?(:device_id => device_id)
  end

  def is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

end
