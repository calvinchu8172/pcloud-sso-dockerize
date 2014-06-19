class PairingController < ApplicationController
  def index
    # @ip = request.remote_ip
    @device_session_list = DeviceSession.where(:ip => request.remote_ip)

    @data = @device_session_list.to_json(
            {:only => 
              [:id], 
             :include => {
                :device => {
                  :only => [:id],
                  :include => 
                    :product 
                }}})

    respond_to do |format|
      format.html # index.html.erb
      format.json { 
        render :json => 
          @device_session_list.to_json(
            {:only => 
              [:id], 
             :include => {
                :device => {
                  :only => [:id],
                  :include => :product
                }
              }
            }
          ) 
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
