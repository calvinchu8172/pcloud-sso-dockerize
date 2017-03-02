require "services/ddns_expire"

namespace :ddns_expire do

  task :cronjob => :set_logger do

    # @rake_log.info "**********cronjob starting...***********"
    # Rake::Task["ddns_expire:delete_fake"].invoke
    # Rake::Task["ddns_expire:create_fake"].invoke

    Rake::Task["ddns_expire:notice"].invoke
    Rake::Task["ddns_expire:delete"].invoke

    # Rake::Task["ddns_expire:test_fake"].invoke
    # @rake_log.info "***********cronjob ending...************"

  end

  task :set_logger => :environment  do
    if Rails.env == "development"
      # @rake_log = Logger.new(STDOUT)
      @rake_log = Services::RakeLogger.rails_log # only for development environment. output to STDOUT and cron.log
    else
      @rake_log = Rails.logger # for production, log will be saved in system log
    end
  end

  desc "create fake data for test"

  DOMAIN = "@example.com"
  NOW_USER = "now"
  NOW_USER_EMAIL = NOW_USER + DOMAIN

  EXPIRE60_USER = "expire60"
  EXPIRE60_USER_EMAIL = EXPIRE60_USER + DOMAIN

  EXPIRE90_USER = "expire90"
  EXPIRE90_USER_EMAIL = EXPIRE90_USER + DOMAIN


  task create_fake: :set_logger do
    # @rake_log.info "start creating fake data..."
    log_array = Array.new
    # create a ddns record last active now
    log_array << create_data(NOW_USER_EMAIL, "1.1.1.1", NOW_USER, Time.now.to_i, Time.now.to_i - 1)
    # create a ddns record last active 60 days ago
    log_array << create_data(EXPIRE60_USER_EMAIL, "2.2.2.2", EXPIRE60_USER, 65.days.ago.to_i, 60.days.ago.to_i)
    # create a ddns record last active 90 days ago
    log_array << create_data(EXPIRE90_USER_EMAIL, "3.3.3.3", EXPIRE90_USER, 100.days.ago.to_i, 90.days.ago.to_i)

    info = {
      :event => "create fake data",
      :count => log_array.size,
      :result => log_array
      }.to_json

    @rake_log.info info

    # @rake_log.info "end creating fake data..."
  end

  def create_data(email, ip, hostname, signin_time, signout_time)
    return "#{email} has been existed." if User.find_by(email: email)

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
    # @rake_log.info "  Create record: #{user.email}"

    route53, ip, result, error = Services::DdnsExpire.create_route53_record(ddns)

    info = {
      :user => user.email,
      :route53 => {
        :route53_record => route53,
        :ip => ip,
        :result => result,
        :error => error
      }
    }
  end


  desc "delete fake data"
  task delete_fake: :set_logger do
    log_array = Array.new
    # @rake_log.info "start deleting fake data..."
    log_array << delete_data(NOW_USER_EMAIL)
    log_array << delete_data(EXPIRE60_USER_EMAIL)
    log_array << delete_data(EXPIRE90_USER_EMAIL)

    info = {
      :event => "delete fake data",
      :count => log_array.size,
      :result => log_array
      }.to_json

    @rake_log.info info

    # @rake_log.info "end deleting fake data..."
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
    # @rake_log.info "  Delete record: #{user.email}"

    route53, info, result, error = Services::DdnsExpire.delete_route53_record(ddns) if ddns

    info = {
      :user => user.email,
      :route53 => {
        :route53_record => route53,
        :info => info,
        :result => result,
        :error => error
      }
    }
  end

  desc "check result after processing"
  task test_fake: :set_logger do
    # @rake_log.info "start checking the result..."
    log_array = Array.new
    log_array << check_ddns_record(NOW_USER_EMAIL)
    log_array << check_ddns_record(EXPIRE60_USER_EMAIL)
    log_array << check_ddns_record(EXPIRE90_USER_EMAIL)
    info = {
      :event => "check fake",
      :result => log_array
    }.to_json
    @rake_log.info info
    # @rake_log.info "end checking the result..."
  end

  def check_ddns_record(email)
    user = User.find_by(email: email)
    return "#{email} not found" if user.nil?

    pairing = Pairing.find_by(user: user)
    return "#{email} pairing not found" if pairing.nil?

    ddns = Ddns.find_by(device: pairing.device)
    if ddns
      if ddns.status.nil?
        return "#{user.email} DDNS record still exists. DDNS status: nil"
      else
        return "#{user.email} DDNS record still exists. DDNS status: #{ddns.status}"
      end
    else
      return "#{user.email} DDNS record has been deleted."
    end
  end

  desc "notice use by email if ddns has expired for 60 days"
  task :notice => :set_logger do
    # @rake_log.info "start noticing by email..."
    log_array = Services::DdnsExpire.notice

    info = {
      :event => "[DDNS_CRON] notice by email",
      :count => log_array.size,
      :result => log_array
    }.to_json

    @rake_log.info info

    # @rake_log.info "end noticing by email..."
  end

  desc "delete ddns if ddns has expired for 90 days"
  task :delete => :set_logger do
    # @rake_log.info "start deleting ddns..."
    log_array = Services::DdnsExpire.delete

    info = {
      :event => "[DDNS_CRON] delete ddns and route53",
      :count => log_array.size,
      :result => log_array
    }.to_json

    @rake_log.info info

    # @rake_log.info "end deleting ddns..."
  end

end
