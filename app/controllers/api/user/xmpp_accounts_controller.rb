class Api::User::XmppAccountsController < Api::Base
  before_filter :authenticate_user_by_token, only: :update
  def update
    xmpp_info = current_token_user.apply_for_xmpp_account
    render :json =>  xmpp_info
  end
end
