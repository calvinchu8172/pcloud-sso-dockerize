module GraphData

  def graph_1_1(period, start_date, end_date)
    @table_name  = "註冊數量統計表"
    @y_axis_name = "註冊數量"
    @columns     = [["時間"],["USER註冊數量(含OAuth數量)"],["OAuth註冊數量"],["Device配對數量(裝置配對現況)"]]
    @data1       = User.select("date(created_at) as create_date","#{period} as time_axis","count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2       = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3       = Pairing.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@table_name, @columns, @data1, @data2, @data3]
  end

  def graph_1_2(period, start_date, end_date)
    @table_name  = "OAuth數量統計表"
    @y_axis_name = "Oauth註冊數量"
    @columns     = [["時間"],["G+註冊數量"],["FB註冊數量"]]
    @data1       = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date, provider: "google_oauth2").group(period).order(:created_at)
    @data2       = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date, provider: "facebook").group(period).order(:created_at)
    return [@table_name, @columns, @data1, @data2]
  end

  def graph_1_3(period, start_date, end_date)
    @table_name  = "APP註冊數量統計表"
    @y_axis_name = "APP註冊數量"
    @columns     = [["時間"],["Email註冊數量"],["OAuth註冊數量"]]
    @data1       = User.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where("os = ? or os = ?", "ios", "android").where("oauth = ?", "email").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2       = User.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where("os = ? or os = ?", "ios", "android").where("oauth = ? or oauth = ?", "facebook", "google_oauth2").where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@table_name, @columns, @data1, @data2]
  end

  def graph_1_4(period, start_date, end_date)
    @table_name  = "登入數量統計表"
    @y_axis_name = "登入次數"
    @columns     = [["時間"],["總登入數量"],["Portal登入數量"],["APP登入數量(含紀錄帳號 token驗證)"]]
    @data1       = LoginLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where.not( :sign_in_at => nil ).where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2       = LoginLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where.not( :sign_in_at => nil ).where(:os => 'web').where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3       = LoginLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where.not( :sign_in_at => nil ).where("os = ? or os = ?", "ios", "android").where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@table_name, @columns, @data1, @data2, @data3]
  end

  def graph_2_1(period, start_date, end_date)
    @table_name  = "裝置註冊數量統計表"
    @y_axis_name = "裝置註冊數量"
    @columns     = [["時間"]]
    return_array = [@table_name, @columns]
    i = 1
    @model = Product.select('id', 'model_class_name').order('id')
    @model.each do |m|
      @columns << [m.model_class_name]
      data = Device.select("date(created_at) as create_date", "#{period} as time_axis", "count(*) as value_count", :product_id).where(created_at: start_date..end_date, product_id: m.id).group(period).order(:created_at)
      instance_variable_set("@data#{i}", data)
      return_array << instance_variable_get("@data#{i}")
      i += 1
    end
    return return_array
  end

  def graph_2_2(period, start_date, end_date)
    @table_name  = "裝置配對數量"
    @y_axis_name = "裝置配對數量"
    @columns     = [["時間"]]
    return_array = [@table_name, @columns]
    i = 1
    @model = Pairing.select("distinct (select `product_id` from `devices` where `id`=`device_id`) as model_id", "(select `name` from `products` where `id`=`model_id`) as model_class_name").order("model_id")
    @model.each do |m|
      @columns << [m.model_class_name]
      data = Pairing.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date, device_id: Device.where(product_id: m.model_id).pluck(:id)).group(period).order(:created_at)
      # data = Pairing.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).where("device_id IN (SELECT id FROM devices WHERE product_id = #{m.model_id})").group(period).order(:created_at)
      instance_variable_set("@data#{i}", data)
      return_array << instance_variable_get("@data#{i}")
      i += 1
    end
    return return_array
  end

  def graph_2_3(period, start_date, end_date)
    @table_name  = "裝置未配對數量"
    @y_axis_name = "裝置未配對數量"
    @columns     = [["時間"]]
    return_array = [@table_name, @columns]
    i = 1
    @model = Device.select("product_id as model_id", "(select `name` from `products` where id=`product_id`) as model_class_name").group(:product_id).order(:product_id)
    @model.each do |m|
      @columns << [m.model_class_name]
      data = Device.includes(:pairing).select("date(created_at) as create_date", "#{period} as time_axis", "count(*) as value_count", :product_id).where(created_at: start_date..end_date, product_id: m.model_id).where.not(id: Pairing.pluck(:device_id)).group(period).order(:created_at)
      # data = Device.includes(:pairing).select("date(created_at) as create_date", "#{period} as time_axis", "count(*) as value_count", :product_id).where(created_at: start_date..end_date, product_id: m.model_id).where("id NOT IN (SELECT device_id FROM pairings)").group(period).order(:created_at) # Carter solution
      instance_variable_set("@data#{i}", data)
      return_array << instance_variable_get("@data#{i}")
      i += 1
    end
    return return_array
  end

  def graph_3_1(period, start_date, end_date)
    @table_name  = "配對歷程"
    @y_axis_name = "次數"
    @columns     = [["時間"],["配對數"],["解除配對數"],["NAS解除數"]]
    @data1       = PairingLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:status => 'pair').where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2       = PairingLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:status => 'unpair').where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3       = PairingLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:status => 'reset').where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@table_name, @columns, @data1, @data2, @data3]
  end

  def graph_3_3(period, start_date, end_date)
    @table_name  = "帳號與設備數量統計表"
    @y_axis_name = "帳號數"
    @columns     = [["帳號配對裝置數"],["帳號數"]]
    pairings = Pairing.joins(device: :product)
    user_pairing_amount = Pairing.joins(device: :product).select('user_id', 'count(*) as pairing_count').group('user_id').order("pairing_count")
    value_hash = {}
    user_pairing_amount.each do |item|
      value_hash[item['pairing_count']] = 0 if value_hash[item['pairing_count']].blank?
      value_hash[item['pairing_count']] = value_hash[item['pairing_count']] + 1
    end
    @data1 = []
    value_hash.map do | user_pairing_device_count ,user_count |
      @data1 << { 'product_model' => "#{user_pairing_device_count}台數量", 'value_count' => user_count }
    end
    return [@table_name, @columns, @data1]
  end

  def graph_5_1(period, start_date, end_date)
    @table_name  = "使用分享功能的NAS總數量 & NAS總數量 (依Model區分)"
    @y_axis_name = "裝置數量"
    @columns     = [["Model"],["分享NAS數量"],["NAS總數量(已配對數)"]]
    accepted_users = AcceptedUser.joins(invitation: { device: :product })
    pairings = Pairing.joins(device: :product)
    @data1 = accepted_users.select('model_class_name as product_model', 'count(distinct device_id) as value_count').group('model_class_name')
    @data2 = pairings.select('model_class_name as product_model', 'count(*) as value_count').group('model_class_name')
    return [@table_name, @columns, @data1, @data2]
  end

  def graph_5_2(period, start_date, end_date)
    @table_name  = "使用分享功能的NAS數量 & 分享人數 (依Model區分)"
    @y_axis_name = "數量"
    @columns     = [["Model"],["分享NAS數量"],["分享人數(不分成功失敗)"]]
    accepted_users = AcceptedUser.joins(invitation: { device: :product })
    @data1 = accepted_users.select('model_class_name as product_model', 'count(distinct device_id) as value_count').group('model_class_name')
    @data2 = accepted_users.select('model_class_name as product_model', 'count(*) as value_count').group('model_class_name')
    return [@table_name, @columns, @data1, @data2]
  end

  def graph_5_3(period="month(created_at)", start_date="2015-9-01", end_date="2015-11-01")
    @table_name  = "沒有NAS的被邀請者人數表"
    @y_axis_name = "人數"
    @columns     = [["型號"],["沒有NAS的被邀請者人數(邀請成功)"]]
    @data1       = Array.new
    #row[0] = name , row[1] = count
    sql = 'SELECT  `products`.name as `name` ,count( `accepted_users`.user_id )
            FROM `accepted_users`
              INNER JOIN `invitations` ON `accepted_users`.invitation_id =  `invitations`.id
              INNER JOIN `devices` ON  `invitations`.device_id = `devices`.id
              INNER JOIN `products` ON `devices`.product_id  = `products`.id
            WHERE `user_id` NOT IN ( SELECT `user_id` from `pairings` where 1 )
            GROUP BY name'
    records_array = ActiveRecord::Base.connection.execute(sql)
    records_array.each do |row|
      @data1 << { 'product_model' => row[0] , 'value_count' => row[1] }
    end
    return [@table_name, @columns, @data1]
  end

  def graph_5_4(period="month(created_at)", start_date="2015-9-01", end_date="2015-11-01")
    @table_name  = "NAS分享次數表"
    @y_axis_name = "NAS邀請分享次數"
    @columns     = [["型號"],["邀請分享次數"]]
    @data1       = Array.new
    #row[0] = name , row[1] = count
    sql = 'SELECT `products`.name as \'name\' ,  count( `invitations`.id ) as \'sum\'
            FROM `invitations`
              JOIN `devices` on `invitations`.device_id = `devices`.id
              JOIN `products` on `devices`.product_id = `products`.id
            WHERE 1
            GROUP BY name'
    records_array = ActiveRecord::Base.connection.execute(sql)
    records_array.each do |row|
      @data1 << { 'product_model' => row[0] , 'value_count' => row[1] }
    end
    return [@table_name, @columns, @data1]
  end

  def graph_5_5(period="month(created_at)", start_date="2015-9-01", end_date="2015-11-01")
    @table_name  = "NAS分享成功人數統計表"
    @y_axis_name = "邀請成功次數"
    @columns     = [["型號"],["分享資料夾使用人數-邀請成功"]]
    @data1       = Array.new
    #row[0] = name , row[1] = count
    sql = 'SELECT `products`.name as `name` , count( `accepted_users`.user_id ) as count
            FROM `accepted_users`
              INNER JOIN `invitations` ON `accepted_users`.invitation_id =  `invitations`.id
              INNER JOIN `devices` ON  `invitations`.device_id = `devices`.id
              INNER JOIN `products` ON `devices`.product_id  = `products`.id
            WHERE `accepted_users`.status = 1
            GROUP BY name'
    records_array = ActiveRecord::Base.connection.execute(sql)
    records_array.each do |row|
      @data1 << { 'product_model' => row[0] , 'value_count' => row[1] }
    end
    return [@table_name, @columns, @data1]
  end

  def unavailable
    @table_name  = "請由選單點選欲呈現的圖表"
    @y_axis_name = ""
    @columns     = [[""],[""]]
    return [@table_name, @columns]
  end

end
