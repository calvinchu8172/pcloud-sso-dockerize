class DdnsMailer < ActionMailer::Base
  default from: "no-reply@zyxel.me"
  # layout 'mailer'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.ddns_mailer.notify_comment.subject
  #
  def notify_comment(user)
      @greeting = "Hi! This is test mail from Pcloud"

      # @user = User.first # for test
      @user = user
      I18n.with_locale(@user.language) do
        mail to: @user.email
      end
  end

end
