class DeviceIndicatorSession
  include Redis::Objects

  attr_accessor :id

  self.redis_prefix=('device:indicator')
  counter :index, :key => 'device:indicator:session:index'
  hash_key :session, :expiration => 30.seconds

  def self.create
    session = self.new
    session.id = session.index.increment
    session
  end

  def self.find id
    session = self.new
    session.id = id
    session
  end
end
