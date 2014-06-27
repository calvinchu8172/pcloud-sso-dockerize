class UnpairingController < ApplicationController
  before_action :authenticate_user!

  def index
    @device = Pairing.find(params[:id]).device
  end

  def success
    @device = Device.find(params[:id])
  end

  def destroy
    pairing = Pairing.find(params[:id])
    Pairing.find(params[:id]).destroy
    redirect_to "/unpairing/success/" + pairing.device_id.to_s
  end
end
