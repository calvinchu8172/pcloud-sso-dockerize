# /lib/tasks/dev.rake

namespace :dev do

  task :build_xmpp_database => :environment do
    password = ActiveRecord::Base.configurations[Rails.env]["password"]
    ActiveRecord::Base.establish_connection(adapter: "mysql2", password: password)

    Dir[File.expand_path("lib/tasks/build_xmpp_database.sql")].each do |file|
      puts "Excute SQL script: #{file}"
      sql = File.open(file).read
      sql.split(';').each do |sql_statement|
        ActiveRecord::Base.connection.execute(sql_statement)
        puts sql_statement
      end
    end
  end

  task :rebuild => ["db:drop", "db:setup", :fake, :build_xmpp_database]

  task :fake => :environment do

    user = User.create(
      email: "fake@example.com",
      password: "fakepassword",
      password_confirmation: "fakepassword",
      edm_accept: "0",
      agreement: "1",
      confirmed_at: Time.now
      )
    puts "create fake user for developement"
    puts "  email: #{user.email}"
    puts "  password: #{user.password}"

    device = Device.create(
      serial_number: "1234567890",
      mac_address: "112233445566",
      firmware_version: "V4.70(AALS.0)_GPL_20140820",
      product_id: Product.first.id
      )
    puts "create Device"

    device2 = Device.create(
      serial_number: "0123456789",
      mac_address: "001122334455",
      firmware_version: "V4.70(AALS.0)_GPL_20140820",
      product_id: Product.first.id
      )
    puts "create Device"


    pairing = Pairing.create(
        user_id: user.id,
        device_id: device.id,
        ownership: "0"
      )
    pairing2 = Pairing.create(
        user_id: user.id,
        device_id: device2.id,
        ownership: "0"
      )
    puts "create Pairing"

    ddns = Ddns.create(
      device_id: device.id,
      ip_address: "1.2.3.4",
      domain_id: Domain.first.id,
      hostname: "test"
      )
    puts "create DDNS"

  end

  task :notice => :environment do
    job_last_scan_time = 10.minutes.to_i

    WARNING_TIME = 60.days.to_i
    DELETE_TIME = 90.days.to_i
    current_time = Time.now.to_i

    # warning_ddns = Ddns.where(status: [0, 1]) #for test
    warning_ddns = Ddns.where(status: [0])
    warning_device_account = Array.new
    warning_ddns.each do |ddns|
      warning_device_account << 'd' + ddns.device.mac_address.gsub(':', '-') + '-' + ddns.device.serial_number.gsub(/([^\w])/, '-')
    end


    # xmpp_users = XmppLast.where(["last_signout_at + ? + ? > ?", WARNING_TIME, job_last_scan_time, current_time])
    xmpp_users = XmppLast.where(["last_signin_at = ? ", 1437553528]) #for test
    candidate_device_account = Array.new
    xmpp_users.each do |xmpp_user|
      if xmpp_user.online?
        candidate_device_account << xmpp_user.username
      end
    end

    # intersection_account = warning_device_account & candidate_device_account
    intersection_account = warning_device_account + candidate_device_account #for test


    intersection_account_mac_address_and_serial_number = Array.new
    intersection_account.each do |username|
      username.slice!(0)
      username = username.split("-")
      intersection_account_mac_address_and_serial_number << username
    end

    warning_users = Array.new
    intersection_account_mac_address_and_serial_number.each do |i|
      # Device.where({:mac_address => i[0], :serial_number => i[1]}).pairing.first.user.email
      a = Device.find_by(mac_address: i[0], serial_number: i[1])

      if a.present? && a.pairing.present? && a.pairing.first.user.present?
        warning_users << a.pairing.first.user.email

        a.ddns.status = 1 # set device.ddns = 1 warning 但是ddns有before_save filter所以無法save

        user = a.pairing.first.user
        try_user = User.first #for test

        # DdnsMailer.notify_comment(try_user).deliver
        puts Time.now.to_s + " Sent mail to " + "#{ user.first_name }" + " : " + "#{ user.email }"

      end

      # sleep 10

    end

    # binding.pry

  end

  task :delete => :environment do

    # device_last_logout_time = Time.new(2015, 10, 31, 0, 0, 0, "+08:00")
    job_last_scan_time = 10.minutes.to_i

    WARNING_TIME = 60.days.to_i
    DELETE_TIME = 90.days.to_i
    current_time = Time.now.to_i

    # warning_ddns = Ddns.where(status: [0, 1]) #for test
    warning_ddns = Ddns.where(status: [1])
    warning_device_account = Array.new
    warning_ddns.each do |ddns|
      warning_device_account << 'd' + ddns.device.mac_address.gsub(':', '-') + '-' + ddns.device.serial_number.gsub(/([^\w])/, '-')
    end


    # xmpp_users = XmppLast.where(["last_signout_at + ? + ? > ?", DELETE_TIME, job_last_scan_time, current_time])
    xmpp_users = XmppLast.where(["last_signin_at = ? ", 1437553528]) #for test
    candidate_device_account = Array.new
    xmpp_users.each do |xmpp_user|
      if xmpp_user.online?
        candidate_device_account << xmpp_user.username
      end
    end

    # intersection_account = warning_device_account & candidate_device_account
    intersection_account = warning_device_account + candidate_device_account #for test


    intersection_account_mac_address_and_serial_number = Array.new
    intersection_account.each do |username|
      username.slice!(0)
      username = username.split("-")
      intersection_account_mac_address_and_serial_number << username
    end

    warning_users = Array.new
    intersection_account_mac_address_and_serial_number.each do |i|
      # Device.where({:mac_address => i[0], :serial_number => i[1]}).pairing.first.user.email
      a = Device.find_by(mac_address: i[0], serial_number: i[1])

      if a.present? && a.pairing.present? && a.pairing.first.user.present?
        warning_users << a.pairing.first.user.email

        a.ddns.status = 1 # set device.ddns = 1 warning 但是ddns有before_save filter所以無法save
        a.ddns.destroy

        user = a.pairing.first.user
        try_user = User.first #for test

        # DdnsMailer.notify_comment(try_user).deliver
        # puts Time.now.to_s + " Sent mail to " + "#{ user.first_name }" + " : " + "#{ user.email }"
        puts Time.now.to_s + " Delete DDNS " + "#{ user.first_name }" + " : " + "#{ user.email }"

      end

      # sleep 10

    end

    # binding.pry

  end

end
