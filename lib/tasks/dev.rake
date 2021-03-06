# /lib/tasks/dev.rake

namespace :dev do

  task :rebuild => ["db:drop", "db:setup", :fake]

  task :fake => :environment do

    user = User.new(
      email: "fake@example.com",
      password: "fakepassword",
      password_confirmation: "fakepassword",
      edm_accept: "0",
      agreement: "1"
      )
    user.confirmation_token = Devise.friendly_token
    user.skip_confirmation!
    user.save
    
    puts "create fake user for developement"
    puts "  email: #{user.email}"
    puts "  password: #{user.password}"
    
    user2 = User.new(
      email: "tomohung@ecoworkinc.com",
      password: "tttttttt",
      password_confirmation: "tttttttt",
      edm_accept: "0",
      agreement: "1"
      )
    user2.confirmation_token = Devise.friendly_token
    user2.skip_confirmation!
    user2.save

    puts "create fake user for developement"
    puts "  email: #{user2.email}"
    puts "  password: #{user2.password}"

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

    invitation = Invitation.create(
      key: "key",
      share_point: "sharename",
      permission: "2",
      device_id: device.id,
      expire_count: 5
    )
  end
end

