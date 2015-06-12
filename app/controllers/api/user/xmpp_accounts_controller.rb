class Api::User::XmppAccountsController < Api::Base
  before_filter :authenticate_user_by_token!, only: :update
  def update

    account = Api::User::XmppAccount.new(current_token_user.attributes.merge(update_params))
    account.valid?
    return render json: Api::User::INVALID_SIGNATURE_ERROR, :status => 400 unless account.errors[:signature].blank?

    xmpp_info = current_token_user.apply_for_xmpp_account
    render :json =>  xmpp_info
  end

  private 
    def update_params
      params.permit(:certificate_serial, :signature)
    end
end
