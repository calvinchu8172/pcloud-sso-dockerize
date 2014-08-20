Chef::Log.info("Running deploy/before_migrate.rb...")

execute "bower install" do
  cwd release_path
  command "bower --allow-root install"
end

ruby_block "test if we can set environment variables" do
  block do
    ENV['TEST_VAR'] = "test_foo"
  end
end
