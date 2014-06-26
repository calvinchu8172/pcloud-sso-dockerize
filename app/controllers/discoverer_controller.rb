class DiscovererController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_filter :check_device_available, :only => [:check]

  def index
    
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

  def check
    @device = Device.find(params[:id])
  end

  private 

  def search_available_device
    DeviceSession.where("device_id not in (?)" , PairingSession.handling().select(:device_id))
  end
end
