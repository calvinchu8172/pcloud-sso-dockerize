class MyCloudMailer < Devise::Mailer
  def confirmation_instructions(record, action, opts={})
    devise_mail(record, :confirmation_instructions, opts)
  end
end