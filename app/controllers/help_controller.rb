class HelpController < ApplicationController
  skip_before_action :check_user_confirmation_expire

  def index
  end
end
