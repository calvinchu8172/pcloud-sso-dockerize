Chef::Log.info("Running deploy/before_migrate.rb...")

execute "bower install" do
  cwd release_path
  command "bower --allow-root install"
end
