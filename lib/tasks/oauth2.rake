namespace :oauth2 do

  task :create => :environment do
    puts "Please enter name:"
    name = STDIN.gets.chomp
    puts "Please enter redirect_uri. If you have more, please seperate by space:"
    redirect_uri = STDIN.gets.chomp
    redirect_uri = redirect_uri.split.join("\n")
    puts "Please enter scope, If you have more, please seperate by space. If none, just press enter:"
    scopes = STDIN.gets.chomp
    scopes = scopes.split.join(", ")
    uid = Doorkeeper::OAuth::Helpers::UniqueToken.generate
    secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate
    created_at = Time.now.strftime "%Y-%m-%d %H:%M:%S"
    updated_at = Time.now.strftime "%Y-%m-%d %H:%M:%S"

    sql = "INSERT INTO oauth_applications (name, uid, secret, redirect_uri, scopes, created_at, updated_at)
           VALUES ('#{name}', '#{uid}', '#{secret}', '#{redirect_uri}', '#{scopes}', '#{created_at}', '#{updated_at}');"
    ActiveRecord::Base.connection.execute(sql)

    oauth_app = Doorkeeper::Application.find_by_uid uid
    show_app oauth_app

  end

  task :show => :environment do
    puts "Please enter uid(client_id):"
    uid = STDIN.gets.chomp

    oauth_app = Doorkeeper::Application.find_by_uid uid
    show_app oauth_app

  end

  task :update => :environment do
    puts "Please enter uid(client_id):"
    uid = STDIN.gets.chomp

    oauth_app = Doorkeeper::Application.find_by_uid uid
    show_app oauth_app

    puts "Enter new name if you want to update. If don't, just press enter:"
    name = STDIN.gets.chomp
    if name != ""
      oauth_app.update(name: name, updated_at: Time.now)
    end
    puts oauth_app.name

    puts "Enter new redirect_uri if you want to update. If you have more, please seperate by space. If don't, just press enter:"
    redirect_uri = STDIN.gets.chomp
    redirect_uri = redirect_uri.split.join("\n")
    if redirect_uri != ""
      oauth_app.update(redirect_uri: redirect_uri, updated_at: Time.now)
    end
    puts oauth_app.redirect_uri

    puts "Enter new scopes if you want to update.  If you have more, please seperate by space. If don't, just press enter:"
    scopes = STDIN.gets.chomp
    scopes = scopes.split.join(", ")
    if scopes != ""
      oauth_app.update(scopes: scopes, updated_at: Time.now)
    end
    puts oauth_app.scopes

    oauth_app = Doorkeeper::Application.find_by_uid uid
    show_app oauth_app

  end

  task :delete => :environment do
    puts "Please enter uid(client_id):"
    uid = STDIN.gets.chomp
    oauth_app = Doorkeeper::Application.find_by_uid uid
    show_app oauth_app

    puts "Enter 'y' if you want to delete.  If don't, press any other keys."
    yes = STDIN.gets.chomp
    if yes == 'y'
      oauth_app.destroy
      puts "#{oauth_app.name} with uid: #{oauth_app.uid} is deleted."
    end

  end

  def show_app(oauth_app)
    puts "id:           #{oauth_app.id}"
    puts "name:         #{oauth_app.name}"
    puts "uid:          #{oauth_app.uid}"
    puts "secret:       #{oauth_app.secret}"
    puts "redirect_uri: #{oauth_app.redirect_uri}"
    puts "scopes:       #{oauth_app.scopes}"
    puts "created_at:   #{oauth_app.created_at}"
    puts "updated_at:   #{oauth_app.updated_at}"
  end

end