class DdnsSession < ActiveRecord::Base

  enum status: {start: 0, waiting: 1, success: 2, failure: 3}

  belongs_to :device
end
