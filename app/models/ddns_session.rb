class DdnsSession
  include Redis::Objects
  include Guards::AttrEncryptor

  attr_accessor :id

  self.redis_prefix=('ddns')
  counter :index, :key => 'ddns:session:index'
  hash_key :session, :expiration => 6.hours

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
