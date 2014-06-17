# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


@localip = '127.0.0.1'

12.times do |num|
  
  device_params = {:mac_address => Faker::Number.number(2) + ':' + Faker::Number.number(2) + ':' + Faker::Number.number(2) + ':' + Faker::Number.number(2) + ':' + Faker::Number.number(2) + ':' + Faker::Number.number(2), :serial_number => Faker::Address.building_number, :model_name => Faker::Code.isbn, :firmware_version => 'v' + Faker::Address.zip_code}
  @device = Device.create(device_params)

  ip = @localip
  if(num > 3)
  	ip = Faker::Number.digit + '.' + Faker::Number.digit + '.' + Faker::Number.digit + '.' + Faker::Number.digit
  end
  session_params = {:ip => ip, :xmpp_account => Faker::Internet.user_name, :password => Faker::Internet.password(8)}
  
  @device.create_device_session(session_params)
end
