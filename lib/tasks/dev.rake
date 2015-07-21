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
end
