class UnpairingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_device_paired, :only => [:index, :destroy]

  def index
    @device = Pairing.enabled.find(params[:id]).device
  end

  def success
    @device = Device.find(params[:id])
  end

  def destroy
    pairing = Pairing.find(params[:id])
    pairing.enabled = 0
    pairing.save
    Job::UnpairMessage.new.push_device_id(pairing.device_id.to_s)
    redirect_to "/unpairing/success/" + pairing.device_id.to_s
  end

  private

    def check_device_paired
      pairing = Pairing.find_by_id(params[:id])
      if pairing
        if !user_paired_with?(pairing.id)
          error_action
        end
      else
        error_action
      end
    end

    def user_paired_with?(pairing_id)
      Pairing.enabled.exists?({:id => pairing_id, :user_id => current_user.id})
    end

    def error_action
      flash[:error] = I18n.t("warnings.settings.pairing.not_found")
      redirect_to "/personal/index"
    end
end
