class PersonalController < ApplicationController
  before_action :authenticate_user!
  @@unpairing_device = -1 
  def index
    @pairing = Pairing.where(user_id: current_user.id)
  end

  def upnp
  end

  def ddns
  end

  def unpairing
      @pairing = Pairing.find(params[:id])
      @unpaired_device = false
      # when pairing  
      rescue ActiveRecord::RecordNotFound
        @unpaired_device = true
        @pairing = Device.find(@@unpairing_device)
  end

  def destroy
    pairing = Pairing.find(params[:id])
    @@unpairing_device = pairing.device_id
    Pairing.find(params[:id]).destroy
    redirect_to "/personal/unpairing/"
  end

end
