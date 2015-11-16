class DiagramController < ApplicationController

  def index
    # --------------------
    # Input
    # --------------------
    data_quantity = params[:data_quantity].to_i # 3 Integer
    period_scale  = params[:period_scale].to_i # 1 Integer
    start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    end_date      = Date.parse(params[:end]) # "2015-10-20" Date
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

end
