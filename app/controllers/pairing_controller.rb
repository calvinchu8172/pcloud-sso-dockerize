class PairingController < ApplicationController
  # {0 => 'start', 1 => 'waiting', 2 => 'done', 3 => 'offline', 4 => 'failure'}
  

  before_filter :check_login
  before_filter :check_device_pairing_avaliable, :only => [:check]

  def index
    
    @device_session_list = DeviceSession.where("ip = ? AND device_id not in (?)",  request.remote_ip , ParingSession.where(:user_id => current_user.id).select(:device_id))

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
    device_session = DeviceSession.where(:device_id => device_id)

    pairing_session = PairingSession.where("user_id = ? AND device_id = (?) AND status not in", current_user.id, device_id, )
  end
end
