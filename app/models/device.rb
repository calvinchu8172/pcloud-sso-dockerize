class Device < ActiveRecord::Base
  include Guards::AttrEncryptor

  has_many :pairing

end
