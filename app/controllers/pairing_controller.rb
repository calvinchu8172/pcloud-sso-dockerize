class PairingController < ApplicationController
  def index
    # @ip = request.remote_ip
    @device_session_list = DeviceSession.where(:ip => request.remote_ip)

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
