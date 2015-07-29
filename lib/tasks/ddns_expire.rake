namespace :ddns_expire do
  desc "create fake data for test"

  DOMAIN = "@example.com"
  NOW_USER = "now"
  NOW_USER_EMAIL = NOW_USER + DOMAIN

  EXPIRE60_USER = "expire60"
  EXPIRE60_USER_EMAIL = EXPIRE60_USER + DOMAIN

  EXPIRE90_USER = "expire90"
  EXPIRE90_USER_EMAIL = EXPIRE90_USER + DOMAIN


  task create_fake: :environment do
    # create a ddns record last active now
    create_data(NOW_USER_EMAIL, "1.1.1.1", NOW_USER, Time.now.to_i, Time.now.to_i - 1)

    # create a ddns record last active 60 days ago
    create_data(EXPIRE60_USER_EMAIL, "2.2.2.2", EXPIRE60_USER, 65.days.ago.to_i, 60.days.ago.to_i)

    # create a ddns record last active 90 days ago
    create_data(EXPIRE90_USER_EMAIL, "3.3.3.3", EXPIRE90_USER, 100.days.ago.to_i, 90.days.ago.to_i)
  end

  def create_data(email, ip, hostname, signin_time, signout_time)
    return puts "#{email} has been existed." if User.find_by(email: email)

    user = FactoryGirl.build(:api_user, email: email)
    user.skip_confirmation!
    user.save

    device = FactoryGirl.create(:api_device, product: Product.first)
    pairing = FactoryGirl.create(:pairing, user_id: user.id, device_id: device.id)
    ddns = FactoryGirl.create(:ddns, ip_address: ip, hostname: hostname, domain: Domain.first, device: device)
    xmpp_last = XmppLast.create(username: device.xmpp_username, last_signin_at: signin_time, last_signout_at: signout_time, state: "")
    puts "Create record: #{user.email}"

    Services::DdnsExpire.create_route53_record(ddns)
  end


  desc "delete fake data"
  task delete_fake: :environment do

    delete_data(NOW_USER_EMAIL)
    delete_data(EXPIRE60_USER_EMAIL)
    delete_data(EXPIRE90_USER_EMAIL)

  end

  def delete_data(email)
    user = User.find_by(email: email)
    return if user.nil?
    return if user.devices.first.nil?

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

    Services::DdnsExpire.delete_route53_record(ddns)
  end

  desc "check result after processing"
  task test_fake: :environment do
    check_ddns_record(NOW_USER_EMAIL)
    check_ddns_record(EXPIRE60_USER_EMAIL)
    check_ddns_record(EXPIRE90_USER_EMAIL)
  end

  def check_ddns_record(email)
    user = User.find_by(email: email)
    return puts "Error: #{email} not found" if user.nil?

    pairing = Pairing.find_by(user: user)
    return puts "Error: #{email} pairing not found" if pairing.nil?

    ddns = Ddns.find_by(device: pairing.device)
    if ddns
      puts "Error: #{user.email} DDNS record still exists."
    else
      puts "Success: #{user.email} DDNS record has been deleted."
    end
  end

  desc "notice use by email if ddns has expired for 60 days"
  task :notice => :environment do
    Services::DdnsExpire.notice
  end

  desc "delete ddns if ddns has expired for 90 days"
  task :delete => :environment do
    Services::DdnsExpire.delete
  end

end
