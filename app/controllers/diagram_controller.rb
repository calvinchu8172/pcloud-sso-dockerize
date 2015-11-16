class DiagramController < ApplicationController
  # before_action :admin_graph_auth!
  include GraphData

  def index
    # --------------------
    # Input
    # --------------------
    period_scale      = params[:period_scale].to_i
    graph_data_number = params[:graph_data_number]
    start_date        = Date.parse("2014-11-01") # Date.parse(params[:start])
    end_date          = Date.today
    @grapy_type = 'area'
    # --------------------
    # SQL data: related to data_quantity and period_scale
    # --------------------
    # Scale would be one of this range: date, week or month.
    case period_scale
    when 1
      period = "date(created_at)"
    when 2
      period = "week(created_at)"
    when 3
      period = "month(created_at)"
    else
      period = "month(created_at)" # In case data amount is oversized.
    end

    # Each case corresponds to cases in module GraphData
    case graph_data_number
    when "1_1"
      graph_data = graph_1_1(period, start_date, end_date)
      axis_type = 'date'
    when "1_2"
      graph_data = graph_1_2(period, start_date, end_date)
      axis_type = 'date'
    when "3_3"
      graph_data = graph_3_3(period, start_date, end_date)
      axis_type = 'model'
    when "5_1"
      graph_data = graph_5_1(period, start_date, end_date)
      axis_type = 'model'
    when "5_2"
      graph_data = graph_5_2(period, start_date, end_date)
      axis_type = 'model'
    when "5_3"
      graph_data = graph_5_3(period, start_date, end_date)
      axis_type = 'model'
    when "5_4"
      graph_data = graph_5_4(period, start_date, end_date)
      axis_type = 'model'
    when "5_5"
      graph_data = graph_5_5(period, start_date, end_date)
      axis_type = 'model'
    end

    @data_quantity = graph_data.length - 2
    @columns_name  = graph_data[0]
    @columns       = graph_data[1]
    (3..@data_quantity).each do |l|
      instance_variable_set("@data#{l-2}", graph_data[l-1])
    end

    if  axis_type == 'date'
      grapy_type = 'area'
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
        date_diff = TimeDifference.between(start_date, end_date).in_weeks.ceil.to_i
      when 3
        # For month
        date_diff = TimeDifference.between(start_date, end_date).in_months.ceil.to_i
      else
        # For date
        date_diff  = (end_date - start_date).to_i
      end

      # Accumulation
      accumulation = []
      (1..@data_quantity).each do |a|
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
          if i > 0
            start_date = start_date.next_week
          end
          date_string = start_date.strftime("%Y-W%W")
        when 3
          # Fill month
          if i > 0
            start_date = start_date.next_month
          end
          date_string = start_date.strftime("%Y-%b")
        else
          # Fill date
          date_string = (start_date + i).to_s
        end
        @columns[0] << date_string

        # Fill single value:
        # @value_array = ["value of data1", "value of data2", "value of data3"]
        # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
        value_array = []

        (1..@data_quantity).each do |j|
          value_array[j-1] = ""

          instance_variable_get("@data#{j}").any? do |k|
            case period_scale
            when 1
              search_string = date_string
              time          = k.time_axis.strftime("%Y-%m-%d")
            when 2
              search_string = start_date.strftime("%Y-%U")
              time          = k.create_date.strftime("%Y-%U")
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
        @columns[0] << date_string

        # Fill single value:
        # @value_array = ["value of data1", "value of data2", "value of data3"]
        # @columns = ["value of date", "value of data1", "value of data2", "value of data3"]
        value_array = []

        (1..@data_quantity).each do |j|
          value_array[j-1] = ""

          instance_variable_get("@data#{j}").any? do |k|
            case period_scale
            when 1
              search_string = date_string
              time          = k.time_axis.strftime("%Y-%m-%d")
            when 2
              search_string = start_date.strftime("%Y-%U")
              time          = k.create_date.strftime("%Y-%U")
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
        end # (1..@data_quantity).each do |j| ... end
      end # (0..date_diff).each do |i| ... end

    elsif axis_type == 'model'
      @grapy_type = 'bar'
      model_list = @data1.to_a
      # iterate the model name
      (0..(model_list.count-1)).each do |i|
        model_class_name = model_list[i]['product_model']
        @columns[0] << model_class_name
        value_hash = { model_class_name => 0 }

        # iterate the data variable sequence (1, 2, ....)
        (1..@data_quantity).each do |j|
          # iterate the data variable (data1, data2, ....)
          instance_variable_get("@data#{j}").any? do |k|
            if model_class_name == k['product_model']
              value_hash[model_class_name] = (value_hash[model_class_name] + k['value_count']).to_f
            end
          end
          @columns[j] << value_hash[model_class_name]
          value_hash[model_class_name] = 0
        end # (1..data_quantity).each do |j| ... end
      end # (0..model_list.count-1).each do |i| ... end

    end # if axis_type == 'date' ... elsif axis_type == 'model' ... end
  end

  private

    def admin_graph_auth!
      redis_id = Redis::HashKey.new("admin_graph:" + current_user.id.to_s + ":session")

      unless redis_id['name'] == current_user.email
        redirect_to :root
      end
    end

end
