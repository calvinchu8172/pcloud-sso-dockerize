class DdnsSession
  include Redis::Objects
  attr_accessor :id

  self.redis_prefix=('ddns')
  counter :index, :key => 'ddns:session:index'
  hash_key :session, :expiration => 6.hours
  # enum status: {start: 0, waiting: 1, success: 2, failure: 3}

  # belongs_to :device

  # VALID_DOMAIN_NAME_REGEX = /\A[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+){2,3}\z/
  # validates :full_domain, format: { with: VALID_DOMAIN_NAME_REGEX }

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
