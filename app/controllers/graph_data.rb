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
    @columns_name = "APP註冊數量"
    @columns      = [["時間"],["會員用APP非Oauth註冊數量"],["會員用APP透過Oauth註冊數量"],["裝置配對數量"]]
    @data1        = User.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where("os = ? or os = ?", "ios", "android").where("oauth = ?", "email").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2        = User.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where("os = ? or os = ?", "ios", "android").where("oauth = ? or oauth = ?", "facebook", "google_oauth2").where(created_at: start_date..end_date).group(period).order(:created_at)
    # @data3        =
    return [@columns_name, @columns, @data1, @data2]
  end

  def graph_1_4(period, start_date, end_date)
    @columns_name = "登入的方式與次數"
    @columns      = [["時間"],["會員總登入數量"],["會員用Portal登入數量"],["會員用APP登入數量"]]
    @data1        = LoginLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where.not( :sign_in_at => nil ).where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2        = LoginLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where.not( :sign_in_at => nil ).where(:os => 'web').where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3        = LoginLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where.not( :sign_in_at => nil ).where("os = ? or os = ?", "ios", "android").where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@columns_name, @columns, @data1, @data2, @data3]
  end

  def graph_2_1(period, start_date, end_date)
    @columns_name = "裝置註冊數量統計表(報到數)依Model區分"
    @columns      = [["時間"],["全部裝置註冊數量"],["裝置NAS540"],["裝置NSA325V2"],["裝置NSA325"],["裝置NSA320S"],["裝置NSA310S"]]
    @data1        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:product_id => 30).where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:product_id => 29).where(created_at: start_date..end_date).group(period).order(:created_at)
    @data4        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:product_id => 28).where(created_at: start_date..end_date).group(period).order(:created_at)
    @data5        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:product_id => 27).where(created_at: start_date..end_date).group(period).order(:created_at)
    @data6        = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:product_id => 26).where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@columns_name, @columns, @data1, @data2, @data3, @data4, @data5, @data6]
  end

  def graph_3_1(period, start_date, end_date)
    @columns_name = "配對歷程"
    @columns      = [["時間"],["配對"],["解除配對"],["裝置reset解除配對"]]
    @data1        = PairingLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:status => 'pair').where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2        = PairingLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:status => 'unpair').where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3        = PairingLog.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(:status => 'reset').where(created_at: start_date..end_date).group(period).order(:created_at)
    return [@columns_name, @columns, @data1, @data2, @data3]
  end
end