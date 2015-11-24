# 負責device 跟 user 之間配對流程
# 配對流程的狀態如下
# * start: 配對流程的起始狀態，並會發送 start message 給device，每次開始配對流程開始Bot 都會將之前的配對流程取消
# * waiting: 等待使用者點選device 上確認按鈕的，在收到device的start message的response 開始
# * done: 配對完成，在waiting的狀態下收到
# * offline: 當start message 沒有接收到成功的response，則視為該device 沒有在線上
# * timeout: 在waiting的狀態下，使用者在時間內未對配對流程確認，則判斷為timout
# * cancel: 在配對過程中，隨時可以取消對該裝置的配對程序
# * failure: 在配對過程中，收到device 失敗的回復
#
# 在配對過程中refresh browser 可接續配對過程
# 如果同一個user 點對該裝置再進行一次配對
# 則前一次配對中的流程會被取消
class PairingController < ApplicationController
  include PairingHelper

  before_action :authenticate_user!
  before_action :check_device_available, :only => [:index, :waiting]
  before_action :check_pairing_session, :only => [:check_connection, :reconnect]

  # GET /pairing/index/:id
  # Cancel pairing process if the device is pairing with same user from bot
  def index
    logger.debug('init session:' + @pairing_session.inspect)
    connect_to_device
    redirect_to action: "waiting", id: @device.encoded_id
  end

  # GET /pairing/waiting/:id
  def waiting

    PairingLog.record_pairing_log(@pairing_session["user_id"].to_i, @device.id, @device.ip_address, 'pair')

    return redirect_to action: "index", id: @device.encoded_id if @pairing_session.empty?

    @pairing_session['expire_in'] = @device.pairing_session_expire_in
    logger.debug('pairing_session:' + @pairing_session.inspect);
  end

  # GET /pairing/check_connection/:id
  # for the polling from front end
  # it will check out session is still avaliable
  def check_connection

    check_timeout
    logger.debug('now:' + Time.now().to_f.to_s + ', pairing_session_expire_in:' + @device.pairing_session_expire_in.to_s)

    result = {:status => @pairing_session['status'], :expire_at => @pairing_session['expire_at']}
    result[:expire_in] = @device.pairing_session_expire_in if @pairing_session.empty? || !Device.handling_status.include?(@pairing_session['status'])
    render :json => result
  end

  # GET /pairing/cancel/:id
  # cancel the pairing process
  def cancel
    device = Device.find_by_encoded_id(params[:id])
    pairing = device.pairing_session
    unless pairing.all.empty?
      pairing.bulk_set 'status' => "cancel"
      AwsService.push_to_queue_cancel("pairing", device.id)
      flash[:notice] = I18n.t("warnings.settings.pairing.canceled")
    end

    redirect_to controller: "discoverer", action: "index"
  end

  private

  # 判斷該session 是否已失效
  def check_timeout
    logger.debug("@pairing_session status: #{@pairing_session['status']}")

    expire_in = @device.pairing_session_expire_in.to_i

    if(@pairing_session['status'] == 'start' && (Pairing::WAITING_PERIOD.to_i - expire_in) >= Pairing::START_PERIOD.to_i)
      @device.pairing_session.store('status', :offline)
      @pairing_session['status'] = :offline
      return
    end

    if(@pairing_session['status'] == 'waiting' && expire_in <= 0)
      @device.pairing_session.store('status', :timeout)
      @pairing_session['status'] = :timeout
    end

  end

  # 初始化一個session 並將start 訊息透過queue 打給bot，再由bot 與device溝通
  def connect_to_device

    waiting_expire_at = (Time.now() + Pairing::WAITING_PERIOD).to_i
    job_params = {:user_id => current_user.id,
                  :cloud_id => current_user.encoded_id,
                  :status => :start,
                  :expire_at => waiting_expire_at}

    logger.info("connect to device params:" + job_params.to_s)
    @device.pairing_session.bulk_set(job_params)
    @device.pairing_session.expire((Pairing::WAITING_PERIOD + 0.2.minutes).to_i)

    @pairing_session = job_params

    job = {:job => 'pairing', :device_id => @device.id.to_s}
    AwsService.send_message_to_queue(job)
    @device.pairing_session.bulk_set job_params

    @pairing_session[:expire_in] = Pairing::WAITING_PERIOD.to_i

    logger.info("connect to device session:" + @pairing_session.inspect)
  end

end