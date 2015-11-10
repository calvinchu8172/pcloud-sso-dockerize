class LoginLog < ActiveRecord::Base
  enum status: { web: 1, app: 2 }

  def self.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, status)
    login_log = self.new
    login_log.user_id = user_id
    login_log.sign_in_at = sign_in_at
    login_log.sign_out_at = sign_out_at
    login_log.sign_in_fail_at = sign_in_fail_at
    login_log.sign_in_ip = convert_ip(sign_in_ip)
    login_log.status = status
    login_log.save
  end

  def self.convert_ip(decimal_ip)
    if decimal_ip != nil
      hex_ip = decimal_ip.split('.').map!{|x| x.to_i(10).to_s(16).rjust(2, '0')}.join('')
    end
    # 若是用APP註冊，則尚未用Web登入前都不會有ip，如果APP註冊後，再用APP登入，則ip會保留原來的nil。
    # 若是用WEB註冊，則WEB註冊成功後，就會馬上登入，因此WEB註冊後會有ip
  end

end
