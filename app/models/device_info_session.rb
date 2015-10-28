class DeviceInfoSession
  include Redis::Objects
  include Guards::AttrEncryptor

  attr_accessor :id

  counter :index, :key => 'device:info:session:index'
  self.redis_prefix = 'device:info'
  redis_id_field :id
  hash_key :session

  WAITING_PERIOD = 30.seconds

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

  def self.handling_status
    ['start']
  end

  def expire_in

    waiting_second = DeviceInfoSession::WAITING_PERIOD.to_i
    return 0 if !self.class.handling_status.include?(session.get('status'))

    time_difference = self.session.get('expire_at').to_i - Time.now().to_i
    return time_difference
  end

end