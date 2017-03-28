class Pairing < ActiveRecord::Base
  include Guards::AttrEncryptor

  belongs_to :user
  belongs_to :device

end