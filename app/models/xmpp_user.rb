class XmppUser < ActiveRecord::Base
  include Redis::Objects
  establish_connection "xmpp_#{Rails.env}".to_sym
  # xmpp server db schema
  # DROP TABLE IF EXISTS `users`;
  # CREATE TABLE `users` (
  #   `username` varchar(250) NOT NULL,
  #   `password` text NOT NULL,
  #   `pass_details` text,
  #   `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  #   PRIMARY KEY (`username`)
  # ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


  self.table_name = "users"
  self.redis_prefix = "xmpp"

  value :session

  redis_id_field :username

end