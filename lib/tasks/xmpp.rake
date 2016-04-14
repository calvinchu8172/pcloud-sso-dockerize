namespace :xmpp do

  namespace :db do

    desc 'create xmpp database'
    task create: :environment do
      ActiveRecord::Tasks::DatabaseTasks.create_current("xmpp_#{Rails.env}")
    end

    desc 'drop xmpp database'
    task drop: :environment do
      ActiveRecord::Tasks::DatabaseTasks.drop_current("xmpp_#{Rails.env}")
    end

    desc 'migrate xmpp database'
    task migrate: :environment do
      ActiveRecord::Base.establish_connection("xmpp_#{Rails.env}".to_sym)
      ActiveRecord::Migrator.migrate([Rails.root.join('db/xmpp_migrate').to_s])
    end
  end
end
