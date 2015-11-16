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
  
  def graph_1_3(period, start_date, end_date)
    # @columns_name = ""
    # @columns      = []
    # @data1        = 
    # @data2        = 
    # @data3        = 
    # return [@columns_name, @columns, @data1, @data2, @data3]
  end
  def graph_5_3(period="month(created_at)", start_date="2015-9-01", end_date="2015-11-01")
    @columns_name = "沒有NAS的被邀請者人數"
    @columns      = [["型號"],["沒有NAS的被邀請者人數"]]
    @data1 = Hash.new
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
      @data1[row[0]] = { "create_date" => row[0] , 'time_axis' => row[0] , 'value_count' => row[1]}
    end
    return [@columns_name, @columns, @data1]
  end

  def graph_5_4(period="month(created_at)", start_date="2015-9-01", end_date="2015-11-01")
    @columns_name = "NAS 分享次數"
    @columns      = [["型號"],["分享次數"]]
    @data1 = Hash.new
    #row[0] = name , row[1] = count
    sql = 'SELECT `products`.name as \'name\' ,  count( `invitations`.id ) as \'sum\' 
    FROM `invitations` 
      JOIN `devices` on `invitations`.device_id = `devices`.id 
      JOIN `products` on `devices`.product_id = `products`.id
    WHERE 1 
    GROUP BY name'
    records_array = ActiveRecord::Base.connection.execute(sql)
    records_array.each do |row|
      @data1[row[0]] = { "create_date" => row[0] , 'time_axis' => row[0] , 'value_count' => row[1]}
    end
    return [@columns_name, @columns, @data1]
  end


  def graph_5_5(period="month(created_at)", start_date="2015-9-01", end_date="2015-11-01")
    @columns_name = "NAS 分享資料夾使用人數-邀請成功"
    @columns      = [["型號"],["分享資料夾使用人數-邀請成功"]]
    @data1 = Hash.new
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
      @data1[row[0]] = { "create_date" => row[0] , 'time_axis' => row[0] , 'value_count' => row[1]}
    end
    return [@columns_name, @columns, @data1]
  end
end