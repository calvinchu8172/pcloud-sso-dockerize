class XmppLast < ActiveRecord::Base
  establish_connection "xmpp_#{Rails.env}".to_sym
  alias_attribute :last_signout_at, :seconds

  # CREATE TABLE `last` (
  #   `username` varchar(250) NOT NULL,
  #   `seconds` int(11) NOT NULL,
  #   `state` text NOT NULL,
  #   `last_signin_at` int(11),
  #   PRIMARY KEY (`username`)
  # ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  self.table_name = "last"

  def online?
    last_signin_at > last_signout_at
  end

  def offline?
    last_signin_at < last_signout_at
  end

end
