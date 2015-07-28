class DdnsMailer < ActionMailer::Base
  default from: "myZyXELcloud Service Team <no-reply@zyxel.me>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.ddns_mailer.notify_comment.subject
  #
  def notify_comment(user, device, xmpp_last_username)
      @greeting = "Hi! This is test mail from Pcloud"

      # @user = User.first # for test
      @user = user
      @full_domain = device.ddns.hostname + "." + Domain.first.domain_name
      @last_signout_at = Time.at(xmpp_last_username.last_signout_at)


      I18n.with_locale(@user.language) do
        mail to: @user.email, subject: I18n.t('mailer.subjects.notification')
      end
  end

end
