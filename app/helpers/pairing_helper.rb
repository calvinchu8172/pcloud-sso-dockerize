module PairingHelper

  def check_device_available
    device_id = params[:id]

    if !device_registered?(device_id)
      flash[:alert] = "device not found"
      redirect_to controller: "discoverer", action: "index"
    elsif paired?(device_id)
      flash[:alert] = "device is paired already"
      redirect_to controller: "discoverer", action: "index"
    end

    @device = Device.find device_id
    @session = @device.pairing_session.all

    if handling?(@device.id, current_user.id)
      flash[:alert] = "device is pairing"
      redirect_to controller: "discoverer", action: "index"
    end
  end

  def check_pairing_session
    device_id = params[:id]

    if !device_registered?(device_id)
      render :json => {:id => device_id, :status => 'not registered device'}
    elsif paired?(device_id)
      render :json => {:id => device_id, :status => 'device is paired'}
    end

    @device = Device.find(device_id)
    @session = @device.pairing_session.all

    if handling?(@device.id, current_user.id)
      render :json => {:id => device_id, :status => 'device is pairing'}
    end
  end

  def device_registered?(device_id)
    Device.exists? device_id
  end

  def handling?(device_id, user_id)
    !@session.empty? && @session['user_id'] != current_user.id.to_s
  end

  def paired?(device_id)
    Pairing.owner.exists?(:device_id => device_id)
  end

  def is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

end
