require 'yaml'
require 'erubis'

class PcloudConfigure
  attr_accessor :env, :reference, :pcloud

  def initialize(environment="development")
    @env = environment
    begin
      file_path = "#{Rails.root}/config/personal-cloud-config.#{@env}.yml"
      @reference = YAML.load(File.open(file_path, 'r'))
      @pcloud = @reference['pcloud']
    rescue
      puts "Error: Missing configuration reference file:\n\t#{file_path}\n\nGet this file from:\n\thttps://gitlab.ecoworkinc.com/zyxel/personal-cloud-config"
    end
  end

  def generate_settings(template, target)
    template_path = "#{Rails.root}/config/#{template}"
    target_path =  "#{Rails.root}/config/#{target}"
    save(template_path, target_path)
  end

  protected
  def save(template_path, target_path)
    erb = File.read(template_path)
    eruby = Erubis::Eruby.new(erb)
    puts "Generating #{target_path} ..."
    begin
      File.open(target_path, 'w') do |target|
        target << eruby.evaluate(:env => @env, :pcloud => @pcloud)
      end
      puts "Success!"
    rescue Exception => e
      puts "Error: Failed to generate #{target_path} !!"
      puts e
    end
  end
end

YAML.load(File.open("#{Rails.root}/config/environments.yml")).each do |env|
  desc "Configure app for '#{env}' environment"
  namespace :config do
    task "#{env}" do
      config = PcloudConfigure.new(env)
      config.generate_settings("settings/settings.yml.erb", "settings/#{env}.yml")
      config.generate_settings("database.yml.erb", "database.yml")
      config.generate_settings("mailer.yml.erb", "mailer.yml")
    end
  end
end
