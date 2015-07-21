-- create xmpp server database
DROP DATABASE IF EXISTS mogooseim;
CREATE DATABASE `mogooseim`;
USE `mogooseim`;
CREATE TABLE users (
    username varchar(250) PRIMARY KEY,
    password text NOT NULL,
    pass_details text,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8;
CREATE TABLE last (
    username varchar(250) PRIMARY KEY,
    seconds int NOT NULL,
    state text NOT NULl,
    last_signin_at int NOT NULL
) CHARACTER SET utf8;