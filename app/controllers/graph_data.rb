module GraphData
  
  def graph_1_1(period, start_date, end_date)
    @columns_name = "註冊數量"
    @columns      = [["時間"],["Google註冊數量"],["Facebook註冊數量"],["裝置配對數量"]]
    @data1        = User.select("date(created_at) as create_date","#{period} as time_axis","count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2        = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@columns_name, @columns, @data1, @data2, @data3]
  end

  def graph_1_2(period, start_date, end_date)
    @columns_name = "Oauth註冊數量"
    @columns      = [["時間"],["Google註冊數量"],["Facebook註冊數量"]]
    @data1        = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date, provider: "google_oauth2").group(period).order(:created_at)
    @data2        = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date, provider: "facebook").group(period).order(:created_at)
    return [@columns_name, @columns, @data1, @data2]
  end
  
  def graph_2_2(period, start_date, end_date)
    @columns_name = "裝置配對數量"
    @columns      = [["時間"]]
    return_array  = [@columns_name, @columns]
    # data_hash     = {}
    i = 1
    
    @model = Pairing.select("distinct (select `product_id` from `devices` where `id`=`device_id`) as model_id", "(select `name` from `products` where `id`=`model_id`) as model_class_name").order("model_id")
    @model.each do |m|
      # data_hash[m.model_id] = m.model_class_name
      @columns << [m.model_class_name]
      data = Pairing.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date, device_id: Device.where(product_id: m.model_id).pluck(:id)).group(period).order(:created_at)
      instance_variable_set("@data#{i}", data)
      return_array << instance_variable_get("@data#{i}")
      i += 1
    end

    return return_array
  end

  def graph_2_3(period, start_date, end_date)
    @columns_name = "裝置未配對數量"
    @columns      = [["時間"]]
    return_array  = [@columns_name, @columns]
    # data_hash     = {}
    i = 1
    @model = Device.select("product_id as model_id", "(select `name` from `products` where id=`product_id`) as model_class_name").group(:product_id).order(:product_id)
    @model.each do |m|
      # data_hash[m.model_id] = m.model_class_name
      @columns << [m.model_class_name]
      data = Device.includes(:pairing).select("date(created_at) as create_date", "#{period} as time_axis", "count(*) as value_count", :product_id).where(created_at: start_date..end_date, product_id: m.model_id).where("devices.`id` <> ?", "pairings.device_id").group(period).order(:created_at)
      instance_variable_set("@data#{i}", data)
      return_array << instance_variable_get("@data#{i}")
      i += 1
    end
    return return_array
  end

end
