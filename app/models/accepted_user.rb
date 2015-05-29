class AcceptedUser < ActiveRecord::Base
  belongs_to :invitation
  belongs_to :user
end
