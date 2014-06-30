class DdnsController < ApplicationController
  before_action :authenticate_user!
  before_action :GetDeviceInfo

  def setting
     @ddns_session = Ddns_session.new
  end

  def success
  end

  private

    def GetDeviceInfo
      @device = Device.find(params[:id])
    end
end
