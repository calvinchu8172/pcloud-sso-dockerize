class Api::Devices::OnlineStatusController < Api::Base
  before_filter :validate_params
  
  def update
    device_target = Device.find_by(serial_number: api_permit[:serial_number], mac_address: api_permit[:mac_address])

    device_target.online_status = @device.online_status if @device.online_status.present?
    device_target.wol_status = @device.wol_status if @device.wol_status.present?

    if device_target.save
      render :json => { result: "success", device: device_target }
    else
      render :json => { result: device_target.errors.messages }, status: 400
    end
  end

  def validate_params
    @device = Api::Device::OnlineStatus.new api_permit

    unless @device.valid?
      failure_field = { 
        "004" => "device",
        "007" => "online_status",
        "013" => "certificate_serial",
        "101" => "signature" }

      failure_field.each do |error_code, field|
        unless @device.errors[field].empty?
          return render :json =>  { error_code: error_code, description: @device.errors[field].first }, status: 400
        end
      end
    end
  end

  # def render_error_response error_code
  #   error_descriptions = {
  #     "004" => "Invalid device.",
  #     "007" => "Invalid status.",
  #     "013" => "Invalid certificate_serial.",
  #     # "101" => "Invalid signature." # Api::Device::OnlineStatus SslValidator
  #   }
  #   unless error_descriptions[error_code].nil?
  #     render :json => { error_code: error_code, description: error_descriptions[error_code] }, status: 400
  #   else
  #     render :json => { error_code: error_code, description: "undefined error" }, status: 400
  #   end
  # end

  private

    def api_permit
      params.permit(:mac_address, :serial_number, :online_status, :wol_status, :certificate_serial, :signature)
    end

end