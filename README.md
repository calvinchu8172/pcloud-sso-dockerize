personal cloud restful api 共有兩組db
一組是app 的db,另外一個會直接連至xmpp server的db，直接管理xmpp user
xmpp user schema 如下

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `username` varchar(250) NOT NULL,
  `password` text NOT NULL,
  `pass_details` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;