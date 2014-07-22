class UpnpSession < ActiveRecord::Base

  enum status: {start: 0, form: 1, submit: 2, failure: 3, updated: 4}

  belongs_to :user
  belongs_to :device

end
