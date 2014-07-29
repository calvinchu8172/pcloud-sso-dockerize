class Job

  attr_reader :session

  def initialize
  	
  end

  # Push message to queue
  def push_to_queue(body)
    data = body.merge({:job => get_job_name})
    # get_queue.send_message(data.to_json)
  end

  def push_session_id(session_id)
    push_to_queue({:session_id => session_id})
  end

  def method_missing name, *args
  	if((result = /^push_(.*?)$/.match name) && args.length > 0)
  	  push_to_queue({result[1] => args[0]})
  	else
  	  logger.fatal "method missing name:" + name.to_s + " args:" + args.join(",")
  	  raise NoMethodError.new("NoMethodError")
  	end
  end

  def push(data)
    @session = get_session_model.new data
    if @session.save
      push_session_id @session.id
      return true
    end

    return false
  end

  protected

  def get_job_name
  	if @job_name.nil?
  	  class_name = self.class.name
  	  @job_name = class_name.split('::')[1].downcase
  	  @job_name['message'] = ''
    end 
    return @job_name
  end

  def get_queue
  	@queue = AWS::SQS.new.queues.create(Settings.environments.sqs.name) if @queue.nil?
  	return @queue
  end

  def get_session_model
    class_name = get_job_name.capitalize + 'Session'
    @session_model = class_name.constantize if @session_model.nil?
    return @session_model
  end
end