class WelcomeController < ApplicationController
  before_action :authenticate_user!

  layout 'sso'

  def index
  end

end
