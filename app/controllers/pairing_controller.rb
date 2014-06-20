class PairingController < ApplicationController

  before_filter :check_login

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
end
