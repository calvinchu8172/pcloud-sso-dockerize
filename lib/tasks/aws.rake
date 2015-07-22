namespace :r53 do

  task :check => :environment do

    account = {
      access_key_id: Settings.environments.sqs.attributes.access_key_id,
      secret_access_key: Settings.environments.sqs.attributes.secret_access_key
    }
    zone_id = Settings.environments.zones_info.id
    ddns_name = Settings.environments.ddns + '.'

    target_name = "test." + ddns_name
    target_ip = "127.0.0.1"

    route = AWS::Route53.new(account)

    hosted_zone = route.hosted_zones[zone_id]
    rrsets = hosted_zone.rrsets

    begin
      rrset = rrsets.create(target_name, 'A', ttl: 300, resource_records: [{value: target_ip}])
      puts "Create DDNS record: #{rrset.name}"
      puts "                ip: #{rrset.resource_records.first[:value]}"
    rescue Exception => error
      puts error
    end

    begin
      rrset = rrsets[target_name, 'A']
      info = rrset.delete
      puts "Delete this record: #{rrset.name}, status: #{info.status}"
    rescue Exception => error
      puts error
    end

  end
end

namespace :sqs do
  task :queue => :environment do
    queue_name = Settings.environments.sqs.name

# This will actually send a queue then poll queues
    queue = AWS::SQS.new.queues.named(queue_name)

    message = "test123"
    puts "Send message: #{message}"
    msg = queue.send_message(message)

    queue.receive_message do |msg|
      puts "Got message: #{msg.body}" #test123
    end
    # queue.poll do |msg|  #poll loop
    #   puts "Got message: #{msg.body}"
    # end
  end

end