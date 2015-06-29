class Api::AccountToken
  include ActiveModel::Model
  include Redis::Objects

  value :session

end