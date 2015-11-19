# Preview all emails at http://localhost:3000/rails/mailers/ddns_mailer
class DdnsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/ddns_mailer/notify_comment
  def notify_comment
    DdnsMailer.notify_comment
  end

end
