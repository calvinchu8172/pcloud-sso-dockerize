class Api::Devices::OnlineStatusController < Api::Base
  before_filter :validate_params, :only => :update
  before_action :check_params, :only => :show
  before_action :check_device, :only => :show
  before_action :check_signature, :only => :show

  def show

    begin
      raise Exception unless render_success
    rescue Exception => error
      render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
    end

  end

  def update
    device_target = Device.find_by(serial_number: api_permit[:serial_number], mac_address: api_permit[:mac_address])

    device_target.online_status = @device.online_status if @device.online_status.present?
    device_target.wol_status = @device.wol_status if @device.wol_status.present?

    if device_target.save
      render :json => { result: "success"}
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

    def valid_params
      params.permit(:device_id, :certificate_serial, :signature)
    end

    def check_params
      if valid_params.keys != ["device_id", "certificate_serial", "signature"]
        return render :json => { error_code: "000", description: "Missing required params." }, status: 400
      end
      valid_params.values.each do |value|
        return render :json => { error_code: "000", description: "Missing required params." }, status: 400 if value.blank?
      end
    end

    def check_device
      @device = Device.find_by_encoded_id( valid_params[:device_id] )
      return render :json => { error_code: "004", description: "Invalid device." }, status: 400 if @device.blank?
    end

    def check_signature
      key = valid_params[:certificate_serial] + valid_params[:device_id]
      signature = valid_params[:signature]
      certificate_serial = valid_params[:certificate_serial]
      return render :json => { error_code: "101", description: "Invalid signature." }, status: 400 unless validate_signature(signature, key, certificate_serial)
    end

    def validate_signature(signature, key, serial)
      sha224 = OpenSSL::Digest::SHA224.new
      begin
        result = Api::Certificate.find_public_by_serial(serial).verify(sha224, Base64.decode64(signature), key)
        return result
      rescue
        return false
      end
    end

    def render_success
      render :json => { "device_id" => valid_params[:device_id],
                        "online_status" => @device.online_status }, status: 200
    end

end