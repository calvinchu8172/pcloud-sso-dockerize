namespace :ddns_expire do

  task :cronjob => :set_logger do
  # task :cronjob do
    # binding.pry

    @rake_log.info "**********#{ Time.now } cronjob starting...***********"
    # Rake::Task["ddns_expire:delete_fake"].invoke
    # Rake::Task["ddns_expire:create_fake"].invoke


    Rake::Task["ddns_expire:notice"].invoke
    Rake::Task["ddns_expire:delete"].invoke
    # Rake::Task["ddns_expire:test_fake"].invoke

    # @rake_log.debug "This is a message with level DEBUG"
    # @rake_log.info "This is a message with level INFO"
    # @rake_log.warn "This is a message with level WARN"
    # @rake_log.error "This is a message with level ERROR"
    # @rake_log.fatal "This is a message with level FATAL"

    @rake_log.info "***********#{ Time.now } cronjob ending...************"

  end

  task set_logger: :environment  do
    @rake_log = Services::RakeLogger.log4r
  end

  desc "create fake data for test"

  DOMAIN = "@example.com"
  NOW_USER = "now"
  NOW_USER_EMAIL = NOW_USER + DOMAIN

  EXPIRE60_USER = "expire60"
  EXPIRE60_USER_EMAIL = EXPIRE60_USER + DOMAIN

  EXPIRE90_USER = "expire90"
  EXPIRE90_USER_EMAIL = EXPIRE90_USER + DOMAIN


  task create_fake: :environment do
    puts "start creating fake data..."
    # create a ddns record last active now
    create_data(NOW_USER_EMAIL, "1.1.1.1", NOW_USER, Time.now.to_i, Time.now.to_i - 1)

    # create a ddns record last active 60 days ago
    create_data(EXPIRE60_USER_EMAIL, "2.2.2.2", EXPIRE60_USER, 65.days.ago.to_i, 60.days.ago.to_i)

    # create a ddns record last active 90 days ago
    create_data(EXPIRE90_USER_EMAIL, "3.3.3.3", EXPIRE90_USER, 100.days.ago.to_i, 90.days.ago.to_i)
    puts "end creating fake data..."
  end

  def create_data(email, ip, hostname, signin_time, signout_time)
    return puts "#{email} has been existed." if User.find_by(email: email)

    user = User.new(
      email: email,
      password: "12345678",
      password_confirmation: "12345678",
      edm_accept: "0",
      agreement: "1")

    # user = FactoryGirl.build(:api_user, email: email)
    user.skip_confirmation!
    user.save

    # device = FactoryGirl.create(:api_device, product: Product.first)
    device = nil
    unless device
      device = Api::Device.create(
        serial_number: rand(1000000000..9999999999).to_s,
        mac_address: rand(100000000000..999999999999).to_s,
        firmware_version: "V4.70(AALS.0)_GPL_20140820",
        model_class_name: Product.first.model_class_name,
        product: Product.first)
    end
    # pairing = FactoryGirl.create(:pairing, user_id: user.id, device_id: device.id)
    pairing = Pairing.create(user_id: user.id, device_id: device.id, ownership: "0")

    # ddns = FactoryGirl.create(:ddns, ip_address: ip, hostname: hostname, domain: Domain.first, device: device)
    ddns = Ddns.create(ip_address: ip, hostname: hostname, domain: Domain.first, device: device)
    xmpp_last = XmppLast.create(username: device.xmpp_username, last_signin_at: signin_time, last_signout_at: signout_time, state: "")
    puts "Create record: #{user.email}"

    Services::DdnsExpire.create_route53_record(ddns)
  end


  desc "delete fake data"
  task delete_fake: :environment do
    puts "start deleting fake data..."
    delete_data(NOW_USER_EMAIL)
    delete_data(EXPIRE60_USER_EMAIL)
    delete_data(EXPIRE90_USER_EMAIL)
    puts "end deleting fake data..."
  end

  def delete_data(email)
    user = User.find_by(email: email)
    return if user.nil?
    if user.devices.first.nil?
      user.destroy
      return
    end

    device = Api::Device.find(user.devices.first.id)
    ddns = Ddns.find_by(device: device)
    pairing = Pairing.find_by(device: device)
    xmpp_last = XmppLast.find_by(username: device.xmpp_username)

    xmpp_last.destroy if xmpp_last
    ddns.destroy if ddns
    pairing.destroy if pairing
    device.destroy if device
    user.destroy if user
    puts "Delete record: #{user.email}"

    Services::DdnsExpire.delete_route53_record(ddns) if ddns
  end

  desc "check result after processing"
  task test_fake: :environment do
    puts "start checking the result..."
    check_ddns_record(NOW_USER_EMAIL)
    check_ddns_record(EXPIRE60_USER_EMAIL)
    check_ddns_record(EXPIRE90_USER_EMAIL)
    puts "end checking the result..."
  end

  def check_ddns_record(email)
    user = User.find_by(email: email)
    return puts "Error: #{email} not found" if user.nil?

    pairing = Pairing.find_by(user: user)
    return puts "Error: #{email} pairing not found" if pairing.nil?

    ddns = Ddns.find_by(device: pairing.device)
    if ddns
      if ddns.status.nil?
        puts "  #{user.email} DDNS record still exists. And ddns status is nil"
      else
        puts "  #{user.email} DDNS record still exists. And ddns status is #{ddns.status}"
      end
    else
      puts "  #{user.email} DDNS record has been deleted."
    end
  end

  desc "notice use by email if ddns has expired for 60 days"
  task :notice => :set_logger do
    # @rake_log.info "starting noticing by email..."
    puts "starting noticing by email..."
    Services::DdnsExpire.notice
    # @rake_log.info "end noticing by email..."
    puts "end noticing by email..."
  end

  desc "delete ddns if ddns has expired for 90 days"
  task :delete => :set_logger do
    puts "start deleting ddns..."
    Services::DdnsExpire.delete
    puts "end deleting ddns..."
  end

end
