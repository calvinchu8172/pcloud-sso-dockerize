class OauthController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => :mobile_register
  before_action :adjust_provider, only: [:mobile_checkin, :mobile_register]

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

  # GET /user/1/checkin/:oauth_provider
  def mobile_checkin
    user_id  = params[:user_id]

    @user = Identity.find_by(uid: user_id, provider: @provider)

    if @user.nil?
      render :json => { :error_code => '001',  :description => 'unregistered' }, :status => 400
    elsif @user.user.confirmation_token.nil?
      render :json => { :error_code => '002',  :description => 'not binding yet' }, :status => 400
    else
      render :json => { :result => 'registered', :account => @user.user.email }, :status => 200
    end
  end

  # POST /user/1/register/:oauth_provider
  def mobile_register
    user_id      = params[:user_id]
    access_token = params[:access_token]
    password     = params[:password]

    @user = Identity.find_by(uid: user_id, provider: @provider)

    if !password.length.between?(8, 14)
      render :json => { :error_code => '002',  :description => 'Password has to be 8-14 characters length' }, :status => 400
    elsif !@user.nil?
      render :json => { :error_code => '003',  :description => 'registered account' }, :status => 400
    else
      identity = User.sign_up_fbuser(user_id, access_token, password)
      sign_in identity.user
      redirect_to authenticated_root_path
    end
  end

  private

  def validate_signature
    user_id      = params[:user_id] || ''
    access_token = params[:access_token] || ''
    password     = params[:password] || ''
    certificate  = params[:certificate] || ''
    signature    = params[:signature] || ''

    data             = certificate + user_id + access_token + password
    digest           = OpenSSL::Digest::SHA256.new
    private_key      = OpenSSL::PKey::RSA.new(File.read(private_key_file))
    signature_inside = private_key.sign(digest, data)

    unless signature == signature_inside
      render :json => {:error_code => '005', :description => 'invalid signature'}, :status => 400
    end
  end

  def adjust_provider
    if !['google', 'facebook'].include?(params[:oauth_provider])
      render :file => 'public/404.html', :status => :not_found, :layout => false
    else
      params[:oauth_provider] = 'google_oauth2' if params[:oauth_provider] == 'google'
      @provider = params[:oauth_provider]
    end
  end

end