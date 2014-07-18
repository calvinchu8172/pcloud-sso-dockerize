class DdnsSession < ActiveRecord::Base

  enum status: {start: 0, waiting: 1, success: 2, failure: 3}

  belongs_to :device

  # VALID_DOMAIN_NAME_REGEX = /\A[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+){2,3}\z/
  # validates :full_domain, format: { with: VALID_DOMAIN_NAME_REGEX }
end
