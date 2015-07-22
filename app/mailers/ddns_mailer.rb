class DdnsMailer < ActionMailer::Base
  default from: "no-reply@zyxel.me"
  # layout 'mailer'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.ddns_mailer.notify_comment.subject
  #
  def notify_comment
    @greeting = "Hi! This is test mail from Pcloud"

    mail to: "calvinchu8172@gmail.com"
  end
end
