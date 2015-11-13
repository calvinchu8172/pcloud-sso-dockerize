class DiagramController < ApplicationController
  # before_action :admin_graph_auth!
  
  def index
    # --------------------
    # Input
    # --------------------
    data_quantity = params[:data_quantity].to_i # 3 Integer
    period_scale  = params[:period_scale].to_i # 1 Integer
    start_date    = Date.parse(params[:start]) # "2015-7-20" Date
    end_date      = Date.today # "2015-10-20" Date
    # end_date      = Date.parse(params[:end]) # "2015-10-20" Date

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

    @data1 = User.select("date(created_at) as create_date","#{period} as time_axis","count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data2 = Identity.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)
    @data3 = Device.select("date(created_at) as create_date","#{period} as time_axis", "count(*) as value_count").where(created_at: start_date..end_date).group(period).order(:created_at)

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
      # date_diff = (end_date.cweek - start_date.cweek)
      date_diff = TimeDifference.between(start_date, end_date).in_weeks.ceil.to_i
    when 3
      # For month
      # date_diff = (end_date.month - start_date.month)
      date_diff = TimeDifference.between(start_date, end_date).in_months.ceil.to_i
    else
      # For date
      date_diff  = (end_date - start_date).to_i
    end

    # Accumulation
    accumulation = []
    (1..data_quantity).each do |a|
      accumulation[a-1] = 0
    end

    # Fill data in array per date range
    (0..date_diff).each do |i|

      case period_scale
      when 1
        # Fill date
        date_string = (start_date + i).to_s
      when 2
        # Fill week
        # date_string = "#{start_date.year}-Week#{start_date.cweek + i}"
        if i > 0
          start_date = start_date.next_week
          date_string = start_date.strftime("%Y-W%W")
        else
          date_string = start_date.strftime("%Y-W%W")
        end
      when 3
        # Fill month
        # date_string = "#{start_date.year}-#{start_date.month + i}"
        if i > 0
          start_date = start_date.next_month
          date_string = start_date.strftime("%Y-%b")
        else
          date_string = start_date.strftime("%Y-%b")
        end
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
            search_string = start_date.strftime("%Y-%W")
            time          = k.create_date.strftime("%Y-%W")
          when 3
            search_string = start_date.strftime("%Y-%b")
            time          = k.create_date.strftime("%Y-%b")
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

  private

    def admin_graph_auth!
      redis_id = Redis::HashKey.new("admin_graph:" + current_user.id.to_s + ":session")

      unless redis_id['name'] == current_user.email
        redirect_to :root
      end
    end
end
