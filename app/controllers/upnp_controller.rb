class UpnpController < ApplicationController
  before_action :authenticate_user!
  before_action :GetDeviceInfo

  def search
  end

  def setting
    
  end

  private

    def GetDeviceInfo
      @device = Device.find(params[:id])
    end
end
