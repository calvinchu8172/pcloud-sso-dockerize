class UnpairingController < ApplicationController
  before_action :authenticate_user!
  before_action :check_device_paired, :only => [:index, :destroy]

  #GET /unpairing/index/:device_encrypted_id
  def index
  end

  #GET /unpairing/success/:device_encrypted_id
  def success
    @device = Device.find_by_encrypted_id(params[:id])
  end

  #GET /unpairing/destroy/:device_encrypted_id
  def destroy

    @pairing.destroy
    Job::UnpairMessage.new.push_device_id(@device.id.to_s)
    redirect_to "/unpairing/success/" + @device.escaped_encrypted_id
  end

  private

    def check_device_paired
      @device = Device.find_by_encrypted_id(params[:id])

      return error_action if @device.nil?

      @pairing = @device.pairing.owner.first
      if @pairing
        if !user_paired_with?(@pairing)
          error_action
        end
      else
        error_action
      end
    end

    def user_paired_with?(pairing)
      pairing.ownership == 0 && pairing.user_id == current_user.id
    end

    def error_action
      flash[:error] = I18n.t("warnings.settings.pairing.not_found")
      redirect_to "/personal/index"
    end
end
