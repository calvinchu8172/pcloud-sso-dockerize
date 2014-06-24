<<<<<<< HEAD:app/controllers/pairing_controller.rb
class PairingController < ApplicationController
  include PairingHelper
=======
class DiscovererController < ApplicationController
  
>>>>>>> feature/refactore_config_file:app/controllers/discoverer_controller.rb
  before_action :authenticate_user!
  before_filter :check_device_avaliable,

  def index
<<<<<<< HEAD:app/controllers/pairing_controller.rb
  	device_id = params[:id];
    @session = PairingSession.create(:user_id => current_user.id, :device_id => device_id, :expire_at => (Time.now + (12.minutes)))
    push_to_queue
=======
    
    @device_session_list = search_available_device.where(:ip => request.remote_ip)

    raw_result = Array.new
    @device_session_list.each do |session|

      next if(session.device.product.blank?)
      raw_result.push({:device_id => session.device.id, :product_name => session.device.product.name, :img_url => session.device.product.asset.url})
    end


    @result = raw_result.to_json

    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        render :json => @result
      }
    end
  end

  def find
  end

  def add
    @device = Device.new
  end

  def search
    device = Device.where(params['device']);
    if device.empty?
      flash[:alert] = "device not found"
      redirect_to action: 'add'
    else
      redirect_to action: 'check', id: device.first.id
    end
  end

  def success
  end

  def check
    @device = Device.find(params[:id])
  end



  private 

  def search_available_device
    DeviceSession.where("device_id not in (?) AND device_id not in (?)" , PairingSession.handling_by_user(current_user.id).select(:device_id), Pairing.where(:user_id => current_user.id).select(:device_id))
  end

  def check_device_avaliable

    device_id = params[:id]
    if device_registered?(device_id) 
      flash[:alert] = "device not found"
      redirect_to controller: "pairing", action: "index" 
    elsif handling?(current_user.id, device_id)
      flash[:alert] = "device is pairing"
      redirect_to controller: "pairing", action: "index" 
    elsif paired?(current_user.id, device_id)
      flash[:alert] = "device is paired already"
      redirect_to controller: "pairing", action: "index" 
    end
  end

  def device_registered?(device_id)
    DeviceSession.where(:device_id => device_id).empty?
  end

  def handling?(user_id, device_id)
    !PairingSession.handling_by_user(user_id).where(:device_id => device_id).empty?
>>>>>>> feature/refactore_config_file:app/controllers/discoverer_controller.rb
  end

  def push_to_queue
  	data = {:job => "pair", :session_id => @session.id}
  	sqs = AWS::SQS.new
  	queue = sqs.queues.create()
  	queue.send_message(data.to_json)
  end
end
