class PersonalController < ApplicationController
  before_action :authenticate_user!

  def index
    @pairing = Pairing.enabled.where(user_id: current_user.id, enabled: 1)
    if !@pairing.empty?
      @paired = true
    else
      @paired = false
      # need-add-i18n
      flash[:alert] = "您沒有已配對的設備，請先進行配對！" if current_user.sign_in_count == 0
      redirect_to "/discoverer/index"
    end
  end

end
