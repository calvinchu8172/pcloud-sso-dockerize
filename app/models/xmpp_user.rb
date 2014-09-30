class XmppUser < ActiveRecord::Base
  establish_connection "xmpp_#{Rails.env}"
  
  self.table_name = "users"

end