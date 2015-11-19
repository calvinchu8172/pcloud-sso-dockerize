class DdnsMailer < ActionMailer::Base
  default from: "myZyXELcloud Service Team <no-reply@zyxel.me>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.ddns_mailer.notify_comment.subject
  #

  def notify_comment(user, device, xmpp_last_username, option={})
    
    if option[:mode] == "test"
      
      @greeting = "Hi! This is test mail from Pcloud"

      # @user = User.first # for test
      @user = Fakemailman.new
      @full_domain = "FULL_DOMAIN"
      @last_signout_at = "LAST_SIGNOUT_AT"

      option[:lang] = "en" unless option[:lang]

      I18n.with_locale(option[:lang]) do
        mail to: "test@example.com", subject: I18n.t('mailer.subjects.notification')
      end
      return self
    end
    
      @greeting = "Hi! This is test mail from Pcloud"

      # @user = User.first # for test
      @user = user
      @full_domain = device.ddns.hostname + "." + Domain.first.domain_name
      @last_signout_at = Time.at(xmpp_last_username.last_signout_at)


      I18n.with_locale(@user.language) do
        mail to: @user.email, subject: I18n.t('mailer.subjects.notification')
      end

      puts "Sending real"
  end

end

class Fakemailman
  def first_name
    "USER"
  end
end
