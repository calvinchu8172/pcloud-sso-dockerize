Chef::Log.info("Running deploy/before_migrate.rb...")

execute "bower install" do
  Chef::Log.info("Node: #{node.inspect}")
  Chef::Log.info("Release path is: #{release_path}")
  cwd "#{release_path}"
  command "bower install"
end
