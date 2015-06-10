class Api::Device::Lite
  include Redis::Objects
  attr_accessor :origin_id, #mac_address + serial_number
                :test

  self.redis_prefix= 'device:lite'

  value :ip_address, marshal: true
  value :list, redis_id_field: :test

  def initialize params = {}
    params.each { |key, value| send "#{key}=", value }
  end

  def id
    origin_id
  end

end