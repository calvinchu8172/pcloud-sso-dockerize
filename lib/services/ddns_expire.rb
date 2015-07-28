module Services
  module DdnsExpire
    WARNING_TIME = 60.days.to_i
    DELETE_TIME = 90.days.to_i

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
          puts Time.now.to_s + " Sent mail to " + "#{ user.first_name }" + " : " + "#{ user.email }"

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

          # device.ddns.status = 1
          # device.ddns.ip_address = device.ddns.get_ip_addr
          device.ddns.destroy
          delete_route53_record(device.ddns)

          user = device.pairing.first.user

          # DdnsMailer.notify_comment(user).deliver
          puts Time.now.to_s + " Delete DDNS " + "#{ user.first_name }" + " : " + "#{ user.email }"

        end
      end
    end
  end
end