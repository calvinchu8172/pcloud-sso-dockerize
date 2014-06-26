class PersonalController < ApplicationController
  before_action :authenticate_user!

  def index
    @pairing = Pairing.where(user_id: current_user.id)
  end

  def upnp
  end

  def ddns
  end

  def unpairing
  end
end
