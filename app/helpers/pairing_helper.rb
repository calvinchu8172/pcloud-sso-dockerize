module PairingHelper

  def check_device_avaliable

    device_id = params[:id]
    if !device_registered?(device_id) 
      flash[:alert] = "device not found"
      redirect_to controller: "discoverer", action: "index" 
    elsif handling?(current_user.id, device_id)
      flash[:alert] = "device is pairing"
      redirect_to controller: "discoverer", action: "index" 
    elsif paired?(current_user.id, device_id)
      flash[:alert] = "device is paired already"
      redirect_to controller: "discoverer", action: "index" 
    end
  end
  
  def device_registered?(device_id)
    !DeviceSession.where(:device_id => device_id).empty?
  end

  def handling?(user_id, device_id)
    !PairingSession.handling().where(:device_id => device_id).empty?
  end

  def paired?(user_id, device_id)
    !Pairing.where(:user_id => user_id, :device_id => device_id).empty?
  end
end
