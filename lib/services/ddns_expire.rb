module Services
  module DdnsExpire

    @rake_log = Services::RakeLogger.log4r

    WARNING_TIME = 60.days.to_i - 1
    DELETE_TIME = 90.days.to_i - 1

    def self.notice
      current_time = Time.now.to_i

      warning_ddns = Ddns.where(status: [nil, 0])
      warning_device_account = Array.new
      warning_ddns.each do |ddns|
        warning_device_account << 'd' + ddns.device.mac_address.gsub(':', '-') + '-' + ddns.device.serial_number.gsub(/([^\w])/, '-')
      end

      xmpp_users = XmppLast.where([" ? - seconds > ? ", current_time, WARNING_TIME ]) # seconds = last_signout_at
      candidate_device_account = Array.new
      xmpp_users.each do |xmpp_user|
        if xmpp_user.offline?
          candidate_device_account << xmpp_user.username
        end
      end

      intersection_account = warning_device_account & candidate_device_account

      intersection_account_mac_address_and_serial_number = Array.new
      intersection_account.each do |username|
        username.slice!(0)
        username = username.split("-")
        intersection_account_mac_address_and_serial_number << username
      end

      warning_user_emails = Array.new
      intersection_account_mac_address_and_serial_number.each do |i|
        device = Device.find_by(mac_address: i[0], serial_number: i[1])

        if device.present? && device.pairing.present? && device.pairing.first.user.present?

          device.ddns.status = 1
          device.ddns.ip_address = device.ddns.get_ip_addr
          device.ddns.save

          user = device.pairing.first.user
          xmpp_last_username = XmppLast.find_by_decive(device)

          # binding.pry

          DdnsMailer.notify_comment(user, device, xmpp_last_username).deliver_now
          @rake_log.info "  sent mail to DDNS: #{ device.ddns.hostname }.#{device.ddns.domain.domain_name} of Device: #{ device.serial_number } of User: #{ user.email }"

        end
      end
    end

    def self.delete
      current_time = Time.now.to_i

      warning_ddns = Ddns.where(status: [1])
      warning_device_account = Array.new
      warning_ddns.each do |ddns|
        warning_device_account << 'd' + ddns.device.mac_address.gsub(':', '-') + '-' + ddns.device.serial_number.gsub(/([^\w])/, '-')
      end


      xmpp_users = XmppLast.where([" ? - seconds > ? ", current_time, DELETE_TIME ])
      candidate_device_account = Array.new
      xmpp_users.each do |xmpp_user|
        if xmpp_user.offline?
          candidate_device_account << xmpp_user.username
        end
      end

      intersection_account = warning_device_account & candidate_device_account

      intersection_account_mac_address_and_serial_number = Array.new
      intersection_account.each do |username|
        username.slice!(0)
        username = username.split("-")
        intersection_account_mac_address_and_serial_number << username
      end

      warning_user_emails = Array.new
      intersection_account_mac_address_and_serial_number.each do |i|
        device = Device.find_by(mac_address: i[0], serial_number: i[1])

        if device.present? && device.pairing.present? && device.pairing.first.user.present?
          warning_user_emails << device.pairing.first.user.email

          device.ddns.destroy
          delete_route53_record(device.ddns)

          user = device.pairing.first.user
          # DdnsMailer.notify_comment(user).deliver
          @rake_log.info "  delete DDNS: #{ device.ddns.hostname }.#{device.ddns.domain.domain_name} of Device: #{ device.serial_number } of User: #{ user.email }"

        end
      end
    end

    def self.create_route53_record(ddns)
      route = AWS::Route53.new

      zone_id = Settings.environments.zones_info.id
      ddns_name = Settings.environments.ddns + '.'
      target_name = ddns.hostname + "." + ddns_name

      hosted_zone = route.hosted_zones[zone_id]
      rrsets = hosted_zone.rrsets

      begin
        rrset = rrsets.create(target_name, 'A', ttl: 300, resource_records: [{value: ddns.get_ip_addr}])
        @rake_log.info "  Create DDNS record: #{rrset.name}"
        @rake_log.info "                  ip: #{rrset.resource_records.first[:value]}"
      rescue Exception => error
        @rake_log.error error
      end
    end

    def self.delete_route53_record(ddns)
      route = AWS::Route53.new

      zone_id = Settings.environments.zones_info.id
      ddns_name = Settings.environments.ddns + '.'
      target_name = ddns.hostname + "." + ddns_name

      hosted_zone = route.hosted_zones[zone_id]
      rrsets = hosted_zone.rrsets

      begin
        rrset = rrsets[target_name, 'A']
        info = rrset.delete
        @rake_log.info "  Delete DDNS record: #{rrset.name}, status: #{info.status}"
      rescue Exception => error
        @rake_log.error error
      end
    end

  end

end