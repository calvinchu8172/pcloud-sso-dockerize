[![Build Status](https://travis-ci.org/calvinchu8172/pcloud-sso-dockerize.svg?branch=develop)](https://travis-ci.org/calvinchu8172/pcloud-sso-dockerize)

# Personal Cloud SSO 

## Setting

透過 [RailsConfig](https://github.com/railsconfig/rails_config) 管理因為因環境不同需要做不同設定的設定值

* magic_number

用做Restful API 驗證用

* xmpp

  XMPP server 的相關設定，還有正在運行中Bot的名單

* environments

  * api_domain: routes 限制Restful API使用的URL
  * portal_domain: routes 限制Portal使用的URL
  * 使用S3儲存各類產品圖
  * SQS 做portal 與 bot 溝通的管道
  * Route53 做device的ddns server
  * filter_list 是ddns 的保留字列表

* oauth

  支援Facebook 與 Google oauth2

* recaptcha

  [Google reCAPTCHA](http://www.google.com/recaptcha/intro/) 的相關設定

* redis

  * web_host 用於儲存與 Bot 溝通過程中的Session 資訊
  * xmpp_host 儲存 MongooseIM 的 Session，在 portal 中用於判斷 Device 是否在線上

## Databases

Personal Cloud 共有兩組 db

  - app db
  - xmpp db: 由 MongooseIM 管理

#### xmpp db 設定方式

  - rake

  ```
  rake xmpp:db:drop xmpp:db:create xmpp:db:migrate
  ```

  - SQL 語法

  ```
  DROP TABLE IF EXISTS `users`;

  CREATE TABLE `users` (
    `username` varchar(250) NOT NULL,
    `password` text NOT NULL,
    `pass_details` text,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`username`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  CREATE TABLE `last` (
    `username` varchar(250) NOT NULL,
    `seconds` int(11) NOT NULL,
    `state` text NOT NULL,
    `last_signin_at` int(11),
    PRIMARY KEY (`username`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
  ```
