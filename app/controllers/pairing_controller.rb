class PairingController < ApplicationController
  # {0 => 'start', 1 => 'waiting', 2 => 'done', 3 => 'offline', 4 => 'failure'}
  
  before_filter :check_login
  before_filter :check_device_pairing_avaliable, :only => [:check]

  def index
    
    @device_session_list = DeviceSession.where("ip = ? AND device_id not in (?) AND device_id not in (?)",  request.remote_ip , PairingSession.handling_by_user(current_user.id).select(:device_id), Pairing.where(:user_id => current_user.id).select(:device_id))
    # @device_session_list = DeviceSession.where("ip = ?", request.remote_ip)

    @result = @device_session_list.map{|session| {:device_id => session.device.id, :product_name => session.device.product.name, :img_url => session.device.product.asset.url}}.to_json
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
  end

  def unpairing
  end

  def success
  end

  def check
  end



  private 
  def check_device_pairing_avaliable
    device_id = params[:id]
    redirect_to controller: "pairing", action: "index" if device_registered?(device_id) 

  end

  def device_registered?(device_id)
    !(DeviceSession.where(:device_id => device_id).empty?)
  end

  def paring_device?(user_id, device_id)
    !PairingSession.handling_by_user(user_id).where(:device_id => device_id).empty?
  end
end
