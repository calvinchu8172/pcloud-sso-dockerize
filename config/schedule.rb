# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/cron.log'

# every 2.minute do
#   # runner "Model.Method"
#   rake "ddns_expire:notice"
#   # rake "dev:delete"
# end

every :day, :at => '03:00pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '03:30pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '04:00pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '04:30pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '05:00pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '05:30pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '06:00pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '06:30pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end

every :day, :at => '07:00pm' do
  # rake "ddns_expire:delete_fake", :output => 'log/cron_delete_fake.log'
  # rake "ddns_expire:create_fake", :output => 'log/cron_create_fake.log'
  rake "ddns_expire:notice", :output => 'log/cron_notice.log'
  rake "ddns_expire:delete", :output => 'log/cron_delete.log'
end