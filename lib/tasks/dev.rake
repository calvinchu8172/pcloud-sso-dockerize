# /lib/tasks/dev.rake

namespace :dev do

  task :rebuild => ["db:drop", "db:setup", :fake]

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
    # ddns_status = nil
    # device_last_logout_time = Time.new(2015, 10, 31, 0, 0, 0, "+08:00")
    # job_last_scan_time = Time.new(2015, 7, 20, 2, 2, 2, "+8:00")
    WARNING_TIME = 60.days
    DELETE_TIME = 90.days
    current_time = Time.now
    # binding.pry

    # warning_ddns = Ddns.where(status = [0, 1])
    warning_ddns = Ddns.where(status: [0, 1])
    array = Array.new
    warning_ddns.each do |ddns|
      array << ddns.device
    end
    binding.pry

    # DdnsMailer.notify_comment.deliver
    # puts Time.now.to_s + " Sent mail"
  end

  task :delete => :environment do
  end

end
