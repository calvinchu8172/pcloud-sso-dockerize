class OauthController < ApplicationController

  def new
    @user = User.new
  end

  def confirm
    agreement = params[:user][:agreement]
    if agreement == "1"
      # Check provider and user
      identity = User.sign_up_omniauth(session["devise.omniauth_data"], current_user, agreement)
      # Sign In and redirect to root path
      sign_in identity.user
      redirect_to authenticated_root_path
    else
      # Redirect to Sign in page, when user un-agreement the terms
      flash[:notice] = I18n.t('activerecord.errors.messages.accepted')
      redirect_to '/oauth/new'
    end
  end

  def checkin
    provider = params["oauth_provider"]
    user_id = params["user_id"]
    access_token = params["access_token"]

    db_oauth_user = Identity.find_by(uid: user_id, provider: provider)

    if db_oauth_user.nil?
      render :json => { :error_code => 001,  :description => 'unregistered'}, :status => 400
    elsif db_oauth_user.user.confirmation_token.nil?
      render :json => { :error_code => 002,  :description => 'not binding yet'}, :status => 400
    else
      render :json => {"result" => "user_id: #{user_id}, access_token: #{access_token}"}
    end
  end

end