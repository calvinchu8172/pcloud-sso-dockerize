class Api::AuthenticationToken
  include ActiveModel::Model
  include Redis::Objects

  value :session

end