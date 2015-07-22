-- create xmpp server database
CREATE DATABASE IF NOT EXISTS `mogooseim`;
USE `mogooseim`;
CREATE TABLE IF NOT EXISTS users (
    username varchar(250) PRIMARY KEY,
    password text NOT NULL,
    pass_details text,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8;
CREATE TABLE IF NOT EXISTS last (
    username varchar(250) PRIMARY KEY,
    seconds int NOT NULL,
    state text NOT NULl,
    last_signin_at int NOT NULL
) CHARACTER SET utf8;