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

  def self.handling_error_code? code_number
    error_code_list = ['799', '798', '797', '796', '795', '794', '793', '792']
    error_code_list.include?(code_number)
  end
end
