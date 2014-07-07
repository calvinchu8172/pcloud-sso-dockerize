class PersonalController < ApplicationController
  before_action :authenticate_user!

  def index
    @pairing = Pairing.enabled.where(user_id: current_user.id, enabled: 1)
  end

end
