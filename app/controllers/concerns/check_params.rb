module CheckParams
  include ApiErrors

  def check_params(params, filter)

    params.delete("certificate_serial")
    params = params.sort{ |a,z| a<=>z }.to_h
    filter = filter.sort

    compare = filter - params.keys

    if compare.include?(filter[0])
      return render :json => { code: "400.4", message: error("400.4") }, status: 400
    elsif compare.include?(filter[1])
      return render :json => { code: "400.24", message: error("400.24") }, status: 400
    elsif compare.include?(filter[2])
      return render :json => { code: "400.21", message: error("400.21") }, status: 400
    elsif compare.include?(filter[3])
      return render :json => { code: "400.22", message: error("400.22") }, status: 400
    end

  end

end