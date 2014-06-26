module PairingHelper

  def check_device_available

    device_id = params[:id]
    if !device_registered?(device_id) 
      flash[:alert] = "device not found"
      redirect_to controller: "discoverer", action: "index" 
    elsif handling?(device_id)
      flash[:alert] = "device is pairing"
      redirect_to controller: "discoverer", action: "index" 
    elsif paired?(device_id)
      flash[:alert] = "device is paired already"
      redirect_to controller: "discoverer", action: "index" 
    end
  end

  def check_device_registered_for_rest
    render :json => {:error => 'not registered'} unless device_registered?(params[:id]) 
  end
  
  def check_handling_for_rest
    render :json => {:error => 'handling'} if handling?(params[:id])
  end

  def check_paired_for_rest
    render :json => {:error => 'paired'} if paired?(params[:id])
  end

  def device_registered?(device_id)
    !DeviceSession.where(:device_id => device_id).empty?
  end

  def handling?(device_id)
    !PairingSession.handling().where(:device_id => device_id).empty?
  end

  def paired?(device_id)
    !Pairing.where(:device_id => device_id).empty?
  end
end
