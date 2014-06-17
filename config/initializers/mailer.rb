options = YAML.load_file(Rails.root.join('config', 'mailer.yml'))[Rails.env]

default = options.delete 'default'
ActionMailer::Base.default (default.respond_to?(:to_options) ? default.to_options : default)

options.each do |option_key, option|
  ActionMailer::Base.send :"#{option_key}=", (option.respond_to?(:to_options) ? option.to_options : option)
end
