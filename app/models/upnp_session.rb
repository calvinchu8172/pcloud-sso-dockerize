class UpnpSession
  include Redis::Objects

  attr_accessor :id
  self.redis_prefix=('upnp')

  SESSION_INDEX = 'upnp:session:index'

  counter :index, :key => SESSION_INDEX
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
