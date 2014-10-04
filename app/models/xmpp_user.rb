class XmppUser < ActiveRecord::Base
  include Redis::Objects
  establish_connection "xmpp_#{Rails.env}"
  
  self.table_name = "users"
  self.redis_prefix = "xmpp"

  value :session

  redis_id_field :username

end