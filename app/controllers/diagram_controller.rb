class DiagramController < ApplicationController

  def index
    # --------------------
    # Input
    # --------------------
    # data_quantity = params[:data_quantity].to_i # 3 Integer
    data_quantity = 3
    # period_scale  = params[:period_scale].to_i # 1 Integer
    period_scale = 1
    # start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    start_date = Date.parse("2015-7-20")
    # end_date      = Date.parse(params[:end]) # "2015-10-20" Date
    end_date = Date.parse("2015-10-20")
    # Diagram lable name
    @columns = [["時間"],["會員註冊數量"],["Oauth註冊數量"],["裝置配對數量"]]
    # @columns = [["時間"],["會員註冊數量"],["Oauth註冊數量"]]

    # --------------------
    # SQL data: related to data_quantity and period_scale
    # --------------------
    case period_scale
    when 1
      period = "date(created_at)"
    when 2
      period = "week(created_at)"
    when 3
      period = "month(created_at)"
    else
      period = "date(created_at)"
    end

    @data1 = User.select("#{period} as time_axis","count(*) as value_count").where(created_at: start_date..end_date).group(period)
    @data2 = Identity.select("#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period)
    @data3 = Device.select("#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period)

    # --------------------
    # Logic for ploting
    # --------------------
    # Calculate date difference
    case period_scale
    when 1
      # For date
      date_diff  = (end_date - start_date).to_i
    when 2
      # For week
      date_diff = (end_date.cweek - start_date.cweek)
    when 3
      # For month
      date_diff = (end_date.month - start_date.month)
    else
      # For date
      date_diff  = (end_date - start_date).to_i
    end

    # Accumulation
    accumulation = []
    (1..data_quantity).each do |a|
      accumulation[a-1] = 0
    end

    # Fill data in array per day
    (0..date_diff).each do |i|

      case period_scale
      when 1
        # Fill date
        date_string = (start_date + i).to_s
      when 2
        # Fill week
        date_string = "#{start_date.year}-Week#{start_date.cweek + i}"
      when 3
        # Fill month
        date_string = "#{start_date.year}-Month#{start_date.month + i}"
      else
        # Fill date
        date_string = (start_date + i).to_s
      end
      @columns[0] << date_string

      # Fill value:
      # @value_array = ["value of data1", "value of data2", "value of data3"]
      # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
      value_array = []

      (1..data_quantity).each do |j|
        value_array[j-1] = ""

        instance_variable_get("@data#{j}").any? do |k|
          case period_scale
          when 1
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          when 2
            search_string = (start_date.cweek + i)
            time          = k.time_axis
          when 3
            search_string = (start_date.month + i)
            time          = k.time_axis
          else
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          end

          if time == search_string
            value_array[j-1] = k.value_count
          end
        end

        # Accumulation
        unless value_array[j-1].blank?
          accumulation[j-1] += value_array[j-1]
          @columns[j] << accumulation[j-1]
        else
          @columns[j] << accumulation[j-1]
        end

      end

    end

  end


  def app_register
    # --------------------
    # Input
    # --------------------
    # data_quantity = params[:data_quantity].to_i # 3 Integer
    data_quantity = 2
    # period_scale  = params[:period_scale].to_i # 1 Integer
    period_scale = 1
    # start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    start_date = Date.parse("2015-7-20")
    # end_date      = Date.parse(params[:end]) # "2015-10-20" Date
    end_date = Date.parse("2015-11-20")
    # Diagram lable name
    @columns = [["時間"],["會員用APP非Oauth註冊數量"],["會員用APP透過Oauth註冊數量"],["裝置配對數量"]]
    # @columns = [["時間"],["會員註冊數量"],["Oauth註冊數量"]]

    # --------------------
    # SQL data: related to data_quantity and period_scale
    # --------------------
    case period_scale
    when 1
      period = "date(created_at)"
    when 2
      period = "week(created_at)"
    when 3
      period = "month(created_at)"
    else
      period = "date(created_at)"
    end

    @data1 = User.select("#{period} as time_axis","count(*) as value_count").where("os = ? or os = ?", "ios", "android").where("oauth = ?", "email").where(created_at: start_date..end_date).group(period)
    @data2 = User.select("#{period} as time_axis","count(*) as value_count").where("os = ? or os = ?", "ios", "android").where("oauth = ? or oauth = ?", "facebook", "google_oauth2").where(created_at: start_date..end_date).group(period)

    # --------------------
    # Logic for ploting
    # --------------------
    # Calculate date difference
    case period_scale
    when 1
      # For date
      date_diff  = (end_date - start_date).to_i
    when 2
      # For week
      date_diff = (end_date.cweek - start_date.cweek)
    when 3
      # For month
      date_diff = (end_date.month - start_date.month)
    else
      # For date
      date_diff  = (end_date - start_date).to_i
    end

    # Accumulation
    accumulation = []
    (1..data_quantity).each do |a|
      accumulation[a-1] = 0
    end

    # Fill data in array per day
    (0..date_diff).each do |i|

      case period_scale
      when 1
        # Fill date
        date_string = (start_date + i).to_s
      when 2
        # Fill week
        date_string = "#{start_date.year}-Week#{start_date.cweek + i}"
      when 3
        # Fill month
        date_string = "#{start_date.year}-Month#{start_date.month + i}"
      else
        # Fill date
        date_string = (start_date + i).to_s
      end
      @columns[0] << date_string

      # Fill value:
      # @value_array = ["value of data1", "value of data2", "value of data3"]
      # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
      value_array = []

      (1..data_quantity).each do |j|
        value_array[j-1] = ""

        instance_variable_get("@data#{j}").any? do |k|
          case period_scale
          when 1
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          when 2
            search_string = (start_date.cweek + i)
            time          = k.time_axis
          when 3
            search_string = (start_date.month + i)
            time          = k.time_axis
          else
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          end

          if time == search_string
            value_array[j-1] = k.value_count
          end
        end

        # Accumulation
        unless value_array[j-1].blank?
          accumulation[j-1] += value_array[j-1]
          @columns[j] << accumulation[j-1]
        else
          @columns[j] << accumulation[j-1]
        end

      end

    end

  end


  def login_log
    # --------------------
    # Input
    # --------------------
    # data_quantity = params[:data_quantity].to_i # 3 Integer
    data_quantity = 3
    # period_scale  = params[:period_scale].to_i # 1 Integer
    period_scale = 1
    # start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    start_date = Date.parse("2015-7-20")
    # end_date      = Date.parse(params[:end]) # "2015-10-20" Date
    end_date = Date.parse("2015-11-20")
    # Diagram lable name
    @columns = [["時間"],["會員登入數量"],["會員用Portal登入數量"],["會員用APP登入數量"]]
    # @columns = [["時間"],["會員註冊數量"],["Oauth註冊數量"]]

    # --------------------
    # SQL data: related to data_quantity and period_scale
    # --------------------
    case period_scale
    when 1
      period = "date(created_at)"
    when 2
      period = "week(created_at)"
    when 3
      period = "month(created_at)"
    else
      period = "date(created_at)"
    end

    @data1 = LoginLog.select("#{period} as time_axis","count(*) as value_count").where.not( :sign_in_at => nil ).where(created_at: start_date..end_date).group(period)
    @data2 = LoginLog.select("#{period} as time_axis","count(*) as value_count").where.not( :sign_in_at => nil ).where(:os => 'web').where(created_at: start_date..end_date).group(period)
    @data3 = LoginLog.select("#{period} as time_axis","count(*) as value_count").where.not( :sign_in_at => nil ).where("os = ? or os = ?", "ios", "android").where(created_at: start_date..end_date).group(period)


    # --------------------
    # Logic for ploting
    # --------------------
    # Calculate date difference
    case period_scale
    when 1
      # For date
      date_diff  = (end_date - start_date).to_i
    when 2
      # For week
      date_diff = (end_date.cweek - start_date.cweek)
    when 3
      # For month
      date_diff = (end_date.month - start_date.month)
    else
      # For date
      date_diff  = (end_date - start_date).to_i
    end

    # Accumulation
    accumulation = []
    (1..data_quantity).each do |a|
      accumulation[a-1] = 0
    end

    # Fill data in array per day
    (0..date_diff).each do |i|

      case period_scale
      when 1
        # Fill date
        date_string = (start_date + i).to_s
      when 2
        # Fill week
        date_string = "#{start_date.year}-Week#{start_date.cweek + i}"
      when 3
        # Fill month
        date_string = "#{start_date.year}-Month#{start_date.month + i}"
      else
        # Fill date
        date_string = (start_date + i).to_s
      end
      @columns[0] << date_string

      # Fill value:
      # @value_array = ["value of data1", "value of data2", "value of data3"]
      # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
      value_array = []

      (1..data_quantity).each do |j|
        value_array[j-1] = ""

        instance_variable_get("@data#{j}").any? do |k|
          case period_scale
          when 1
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          when 2
            search_string = (start_date.cweek + i)
            time          = k.time_axis
          when 3
            search_string = (start_date.month + i)
            time          = k.time_axis
          else
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          end

          if time == search_string
            value_array[j-1] = k.value_count
          end
        end

        # Accumulation
        unless value_array[j-1].blank?
          accumulation[j-1] += value_array[j-1]
          @columns[j] << accumulation[j-1]
        else
          @columns[j] << accumulation[j-1]
        end

      end

    end

  end


  def device_register
    # --------------------
    # Input
    # --------------------
    # data_quantity = params[:data_quantity].to_i # 3 Integer
    data_quantity = 6
    # period_scale  = params[:period_scale].to_i # 1 Integer
    period_scale = 1
    # start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    start_date = Date.parse("2015-7-20")
    # end_date      = Date.parse(params[:end]) # "2015-10-20" Date
    end_date = Date.parse("2015-11-20")
    # Diagram lable name
    @columns = [["時間"],["全部裝置註冊數量"],["裝置NAS540"],["裝置NSA325V2"],["裝置NSA325"],["裝置NSA320S"],["裝置NSA310S"]]
    # @columns = [["時間"],["會員註冊數量"],["Oauth註冊數量"]]

    # --------------------
    # SQL data: related to data_quantity and period_scale
    # --------------------
    case period_scale
    when 1
      period = "date(created_at)"
    when 2
      period = "week(created_at)"
    when 3
      period = "month(created_at)"
    else
      period = "date(created_at)"
    end

    @data1 = Device.select("#{period} as time_axis","count(*) as value_count").where(created_at: start_date..end_date).group(period)
    @data2 = Device.select("#{period} as time_axis","count(*) as value_count").where(:product_id => 30).where(created_at: start_date..end_date).group(period)
    @data3 = Device.select("#{period} as time_axis","count(*) as value_count").where(:product_id => 29).where(created_at: start_date..end_date).group(period)
    @data4 = Device.select("#{period} as time_axis","count(*) as value_count").where(:product_id => 28).where(created_at: start_date..end_date).group(period)
    @data5 = Device.select("#{period} as time_axis","count(*) as value_count").where(:product_id => 27).where(created_at: start_date..end_date).group(period)
    @data6 = Device.select("#{period} as time_axis","count(*) as value_count").where(:product_id => 27).where(created_at: start_date..end_date).group(period)

    # --------------------
    # Logic for ploting
    # --------------------
    # Calculate date difference
    case period_scale
    when 1
      # For date
      date_diff  = (end_date - start_date).to_i
    when 2
      # For week
      date_diff = (end_date.cweek - start_date.cweek)
    when 3
      # For month
      date_diff = (end_date.month - start_date.month)
    else
      # For date
      date_diff  = (end_date - start_date).to_i
    end

    # Accumulation
    accumulation = []
    (1..data_quantity).each do |a|
      accumulation[a-1] = 0
    end

    # Fill data in array per day
    (0..date_diff).each do |i|

      case period_scale
      when 1
        # Fill date
        date_string = (start_date + i).to_s
      when 2
        # Fill week
        date_string = "#{start_date.year}-Week#{start_date.cweek + i}"
      when 3
        # Fill month
        date_string = "#{start_date.year}-Month#{start_date.month + i}"
      else
        # Fill date
        date_string = (start_date + i).to_s
      end
      @columns[0] << date_string

      # Fill value:
      # @value_array = ["value of data1", "value of data2", "value of data3"]
      # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
      value_array = []

      (1..data_quantity).each do |j|
        value_array[j-1] = ""

        instance_variable_get("@data#{j}").any? do |k|
          case period_scale
          when 1
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          when 2
            search_string = (start_date.cweek + i)
            time          = k.time_axis
          when 3
            search_string = (start_date.month + i)
            time          = k.time_axis
          else
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          end

          if time == search_string
            value_array[j-1] = k.value_count
          end
        end

        # Accumulation
        unless value_array[j-1].blank?
          accumulation[j-1] += value_array[j-1]
          @columns[j] << accumulation[j-1]
        else
          @columns[j] << accumulation[j-1]
        end

      end

    end

  end


  def pairing_log
    # --------------------
    # Input
    # --------------------
    # data_quantity = params[:data_quantity].to_i # 3 Integer
    data_quantity = 3
    # period_scale  = params[:period_scale].to_i # 1 Integer
    period_scale = 1
    # start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    start_date = Date.parse("2015-7-20")
    # end_date      = Date.parse(params[:end]) # "2015-10-20" Date
    end_date = Date.parse("2015-11-20")
    # Diagram lable name
    @columns = [["時間"],["配對"],["解除配對"],["裝置reset解除配對"]]
    # @columns = [["時間"],["會員註冊數量"],["Oauth註冊數量"]]

    # --------------------
    # SQL data: related to data_quantity and period_scale
    # --------------------
    case period_scale
    when 1
      period = "date(created_at)"
    when 2
      period = "week(created_at)"
    when 3
      period = "month(created_at)"
    else
      period = "date(created_at)"
    end

    @data1 = PairingLog.select("#{period} as time_axis","count(*) as value_count").where(:status => 'pair').where(created_at: start_date..end_date).group(period)
    @data2 = PairingLog.select("#{period} as time_axis","count(*) as value_count").where(:status => 'unpair').where(created_at: start_date..end_date).group(period)
    @data3 = PairingLog.select("#{period} as time_axis","count(*) as value_count").where(:status => 'reset').where(created_at: start_date..end_date).group(period)


    # --------------------
    # Logic for ploting
    # --------------------
    # Calculate date difference
    case period_scale
    when 1
      # For date
      date_diff  = (end_date - start_date).to_i
    when 2
      # For week
      date_diff = (end_date.cweek - start_date.cweek)
    when 3
      # For month
      date_diff = (end_date.month - start_date.month)
    else
      # For date
      date_diff  = (end_date - start_date).to_i
    end

    # Accumulation
    accumulation = []
    (1..data_quantity).each do |a|
      accumulation[a-1] = 0
    end

    # Fill data in array per day
    (0..date_diff).each do |i|

      case period_scale
      when 1
        # Fill date
        date_string = (start_date + i).to_s
      when 2
        # Fill week
        date_string = "#{start_date.year}-Week#{start_date.cweek + i}"
      when 3
        # Fill month
        date_string = "#{start_date.year}-Month#{start_date.month + i}"
      else
        # Fill date
        date_string = (start_date + i).to_s
      end
      @columns[0] << date_string

      # Fill value:
      # @value_array = ["value of data1", "value of data2", "value of data3"]
      # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
      value_array = []

      (1..data_quantity).each do |j|
        value_array[j-1] = ""

        instance_variable_get("@data#{j}").any? do |k|
          case period_scale
          when 1
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          when 2
            search_string = (start_date.cweek + i)
            time          = k.time_axis
          when 3
            search_string = (start_date.month + i)
            time          = k.time_axis
          else
            search_string = date_string
            time          = k.time_axis.strftime("%Y-%m-%d")
          end

          if time == search_string
            value_array[j-1] = k.value_count
          end
        end

        # Accumulation
        unless value_array[j-1].blank?
          accumulation[j-1] += value_array[j-1]
          @columns[j] << accumulation[j-1]
        else
          @columns[j] << accumulation[j-1]
        end

      end

    end

  end
end
