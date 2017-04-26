class Api::Devices::AuthorizeController < ApplicationController
  include CheckSignature
  include CheckParams

  skip_before_filter :verify_authenticity_token

  before_action do
    check_header_signature signature
  end

  before_action do
    check_certificate_serial valid_params
  end

  before_action do
    check_signature valid_params, signature
  end

  before_action do
    check_params valid_params, filter
  end

  before_action :query_app
  before_action :query_device
  before_action :query_user
  before_action :query_pairing

  def create

    expires_in = Doorkeeper.configuration.access_token_expires_in
    use_refresh_token = Doorkeeper.configuration.refresh_token_enabled?
    access_token = Doorkeeper::AccessToken.create!(
      application_id:    @app.id,
      resource_owner_id: @user.id,
      scopes:            @app.scopes,
      expires_in:        expires_in,
      use_refresh_token: use_refresh_token
    )

    response =
    {
      data: {
              access_token: access_token.token,
              refresh_token: access_token.refresh_token
            }
    }

    render json: response, status: 200
  end


  private

    def valid_params
      # 會按照 strong parameter 的排序，決定 valid_params 的排序
      params.permit(:app_id, :certificate_serial, :cloud_id, :mac_address, :serial_number)
    end

    def signature
      request.headers["X-Signature"]
    end

    def filter
      ["app_id", "cloud_id", "mac_address", "serial_number"]
    end

    def check_header_signature(signature)
      if signature.nil?
        return render :json => { code: "400.0", message: error("400.0") }, status: 400
      end
    end

    def check_certificate_serial(params)
      unless params.has_key?("certificate_serial")
        return render :json => { code: "400.2", message: error("400.2") }, status: 400
      end

      certificate_serial = Api::Certificate.find_by_serial(params[:certificate_serial])
      if certificate_serial.nil?
        return render :json => { code: "400.3", message: error("400.3") }, status: 400
      end
    end

    def query_app
      @app = Doorkeeper::Application.find_by_uid(valid_params["app_id"])
      if @app.nil?
        return render :json => { code: "400.5", message: error("400.5") }, status: 400
      end
    end

    def query_device
      @device = Device.find_by(mac_address: valid_params["mac_address"], serial_number: valid_params["serial_number"])
      if @device.nil?
        return render :json => { code: "400.24", message: error("400.24") }, status: 400
      end
    end

    def query_user
      @user = User.find_by_encoded_id(valid_params["cloud_id"])
      if @user.nil?
        return render :json => { code: "400.26", message: error("400.26") }, status: 400
      end
    end

    def query_pairing
      @pairing = Pairing.find_by(user_id: @user.id, device_id: @device.id)
      if @pairing.nil?
        return render :json => { code: "403.0", message: error("403.0") }, status: 400
      end
    end

end
