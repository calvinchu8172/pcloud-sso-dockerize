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
    push_to_queue(pairing.device_id.to_s)
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

    # Push message to queue
    def push_to_queue(device_id)
      data = {:job => "unpair", :device_id => device_id}
      sqs = AWS::SQS.new
      queue = sqs.queues.create(Settings.environments.sqs.name)
      queue.send_message(data.to_json)
    end

    def user_paired_with?(pairing_id)
      Pairing.enabled.exists?({:id => pairing_id, :user_id => current_user.id})
    end

    def error_action
      flash[:error] = "您沒有與該device配對，或是該device不存在！"
      redirect_to "/personal/index"
    end
end
