# Paperclip::Attachment.default_options[:url] = Settings.environments.paperclip.default.url #':s3-pcloud-test.s3.amazonaws.com'
# Paperclip::Attachment.default_options[:s3_host_name] = Settings.environments.paperclip.default.s3_host_name #'s3-us-west-2.amazonaws.com'
# Paperclip::Attachment.default_options[:path] = Settings.environments.paperclip.default.path #'/:class/:attachment/:id_partition/:style/:filename'
# Paperclip::Attachment.default_options = Settings.environments.paperclip.default
Settings.environments.paperclip.attachment.default.each do |key, value|
  Paperclip::Attachment.default_options[key] = value
end