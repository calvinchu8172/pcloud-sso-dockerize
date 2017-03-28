module CheckSignature
  include ApiErrors

  def check_signature(params, signature)
    puts "***check signature"
    params = sort_params(params)
    key = params.values.join("")
    certificate_serial = params["certificate_serial"]
    unless validate_signature(signature, key, certificate_serial)
      return render :json => { code: "400.1", message: error("400.1") }, status: 400
    end
  end


  def sort_params(params)
    params = params.sort{ |a,z| a<=>z }.to_h
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

end