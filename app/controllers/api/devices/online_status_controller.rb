class Api::Devices::OnlineStatusController < Api::Base
  before_filter :validate_params
  
  def update

    render_error_response(api_permit[:online_status])
  end

  def validate_params
    @device = Api::Device::OnlineStatus.new api_permit
    unless @device.valid?
      
    end
  end

  def render_error_response error_code
    error_descriptions = {
      "004" => "Invalid device.",
      "007" => "Invalid status.",
      "013" => "Invalid certificate_serial.",
      "101" => "Invalid signature."
    }
    unless error_descriptions[error_code].nil?
      render :json => { error_code: error_code, description: error_descriptions[error_code] }, status: 400
    else
      render :json => { error_code: error_code, description: "undefined error" }, status: 400
    end
  end

  private

    def api_permit
      params.permit(:mac_address, :serial_number, :online_status, :certificate_serial, :signature)
    end

end