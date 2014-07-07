class UnpairingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_device_paired, :only => [:index, :destroy]

  def index
    @device = Pairing.find(params[:id]).device
  end

  def success
    @device = Device.find(params[:id])
  end

  def destroy
    pairing = Pairing.find(params[:id])
    pairing.enabled = 0
    pairing.save
    redirect_to "/unpairing/success/" + pairing.device_id.to_s
  end

  private

    def check_device_paired
      pairing = Pairing.find_by_id(params[:id])
      if pairing
        if !paired?(pairing.id)
          error_action
        end
      else
        error_action
      end
    end

    def paired?(pairing_id)
      Pairing.exists?(['id = ? and user_id = ? and enabled = 1', pairing_id, current_user.id])
    end

    def error_action
      flash[:error] = "您沒有與該device配對，或是該device不存在！"
      redirect_to "/personal/index"
    end
end
