module AwsService
  def self.push_to_queue_cancel(title, tag)
    data = {job: "cancel", title: title, tag: tag}
    send_message_to_queue(data)
  end

  def self.send_message_to_queue(message)
    queue = get_queue
    if queue.nil?
      logger.fatal({ fail_send_queue: message })
    else
      logger.note({ send_queue: message })
      queue.send_message(message.to_json)
    end
  end

  def self.get_queue
    begin
      sqs = AWS::SQS.new
      sqs.queues.named(Settings.environments.sqs.name)
    rescue
      nil
    end
  end

  private
    def self.logger
      Fluent::Logger.service_logger
    end
end
