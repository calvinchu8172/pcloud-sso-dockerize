module ApiErrors

  def error(code)
    error = {
      "400.0" => "Missing Required Header: X-Signature",
      "400.1" => "Invalid signature",
      "400.2" => "Missing Required Parameter: certificate_serial",
      "400.3" => "Invalid certificate_serial",
      "400.4" => "Missing Required Parameter: app_id",
      "400.5" => "Invalid app_id",
      "400.22" => "Missing Required Parameter: mac_address",
      "400.23" => "Missing Required Parameter: serial_number",
      "400.24" => "Device Not Found",
      "400.25" => "Missing Required Parameter: cloud_id",
      "400.26" => "Invalid cloud_id",
      "403.0" => "User Is Not Device Owner"
    }

    error[code]
  end

end