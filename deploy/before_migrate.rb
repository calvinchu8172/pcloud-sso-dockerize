Chef::Log.info("Running deploy/before_migrate.rb...")

execute "bower install" do
  cwd release_path
  command "bower --allow-root install"
end

ruby_block "try to set environment variable SECRET_KEY_BASE" do
  block do
    ENV['SECRET_KEY_BASE'] = "c894834ec3f545ba9f1495e4a68be7db6c25ba3400439349c2e86684845c90fd7a6eccf666cc651c2f1b38a80585c8cf4ed7466a15acdba2b9701402a5af2aef"
  end
end
