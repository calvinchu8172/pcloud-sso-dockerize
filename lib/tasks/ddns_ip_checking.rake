# require "services/ddns_ip_checking"

namespace :ddns_ip_checking do


  desc "compare the ip stored in device session and DB to show ip mismatch data"
  task :check => :set_logger do
    @rake_log.info("****** Start executing ddns_ip_checking:check ******")

    check_all_ddns_ip

    @rake_log.info("****** Finish executing ddns_ip_checking:check ******")
  end



  desc "compare the ip stored in device session and DB to show and fix ip mismatch data"
  task :check_and_fix => :set_logger do
    @rake_log.info("==========  Start executing ddns_ip_checking:check_and_fix ==========")

    Rake::Task["ddns_ip_checking:check"].invoke
    fix_all_incorrect_ddns_ip unless @data_to_fix.empty?

    @rake_log.info("==========  Finish executing ddns_ip_checking:check_and_fix ==========")
  end


  task :set_logger => :environment do
    if Rails.env == "development"
      @rake_log = Services::RakeLogger.rails_log # only for development environment. output to STDOUT and cron.log
    else
      @rake_log = Rails.logger # for staging and production, log will be saved in system log
    end
  end


  def check_all_ddns_ip
    @data_to_fix = Array.new
    ddns = Ddns.includes(:device)
    ddns.each do |ddns|

      device = ddns.device
      device_session = device.session
      next if device_session.nil?

      ip = device_session.get('ip')
      next if ddns.get_ip_addr == ip

      @data_to_fix << {
        ddns: ddns,
        device_id: device.id,
        hostname: ddns.hostname,
        new_ip: ip,
        old_ip: ddns.get_ip_addr
      }
    end

    if @data_to_fix.empty?
      @rake_log.info("All ddns ip are correct!")
    else
      @rake_log.warn("Total Found #{@data_to_fix.count} incorrect ip ddns data to fix ...")
      @rake_log.warn("Details of all incorrect ddns data: #{@data_to_fix.to_json}")
    end
  end

  def fix_all_incorrect_ddns_ip
    update_result = {
      success_update_count: 0,
      failed_creating_ddns_session: [],
      failed_sendinging_queue_message: [],
    }

    @data_to_fix.each do |data|
      ddns = data[:ddns]
      # unless ddns.update(ip_address: data[:new_ip])
      #   @rake_log.info("Update ddns DB record failed ...")
      #   return
      # end

      ddns_session_data = {
        device_id: data[:device_id],
        host_name: data[:hostname],
        domain_name: Settings.environments.ddns,
        status: 'start'
      }

      ddns_session = DdnsSession.create
      begin
        ddns_session.session.bulk_set(ddns_session_data) != 'OK'
      rescue Exception => e
        update_result[:failed_creating_ddns_session] << data.merge({ error_message: e.to_s })
        next
      end

      begin
        job = { :job => 'ddns', :session_id => ddns_session.id }
        AwsService.send_message_to_queue(job)
      rescue Exception => e
        update_result[:failed_sendinging_queue_message] << data.merge({ error_message: e.to_s })
        next
      end
      update_result[:success_update_count] += 1
    end

    if update_result[:failed_creating_ddns_session].empty? && update_result[:failed_sendinging_queue_message].empty?
      @rake_log.info("All incorrect ddns ip has been fixed successfully!")
    else
      @rake_log.error("Some ddns ip updated failed, the details as below:")
      failed_creating_session_list = update_result[:failed_creating_ddns_session]
      @rake_log.error("Failed creating ddns session: #{failed_creating_session_list.to_json}, count: #{failed_creating_session_list.count}")

      failed_sending_queue_list = update_result[:failed_sendinging_queue_message]
      @rake_log.error("Failed sending queue message: #{failed_sending_queue_list.to_json}, count: #{failed_sending_queue_list.count}")

      @rake_log.error("total update count: #{update_result[:success_update_count]}")

      failed_update_count = failed_creating_session_list.count + failed_sending_queue_list.count
      @rake_log.error("total failure count: #{failed_update_count}")
    end
  end


end