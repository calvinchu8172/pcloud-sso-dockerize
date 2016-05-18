class HintController < ApplicationController

  layout 'rwd'

  skip_before_action :check_user_confirmation_expire
  before_action :get_info
  def confirm
  end

  def signup
    if session[:notice]
      @success_info = session[:notice].split(".").first + "."
    end
  end

  def sent
  end

  def reset
  end

  def agrement
  end

  def confirm_sent
  end

  private
    def get_info
      if flash[:notice]
        session[:notice] = flash[:notice]
      end
    end
end
