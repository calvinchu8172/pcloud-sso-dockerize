class Api::User < User
  include Guards::AttrEncryptor
  include Redis::Objects

  hash_key :app_info

end