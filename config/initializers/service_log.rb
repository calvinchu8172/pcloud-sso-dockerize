Fluent::Logger.setup do |config|
  config.tag = 'personal_cloud.' + Settings.environments.name
  config.host = '10.107.10.174'
  config.port = '24224'
end
