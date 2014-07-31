# Ref. http://www.sitepoint.com/looking-xmpp-xmpp4r-gem/
require 'xmpp4r'
require 'xmpp4r/client'
include Jabber

class Bot 
  attr_reader :client

  def initialize jabber_id, password, bot
    @jabber_id = jabber_id
    @jabber_password  = password
    @jabber_bot = bot
  end

  def connect
    jid = JID.new(@jabber_id)
    @client = Client.new jid
    @client.connect
    if @client.auth @jabber_password 
      @status = 'good'
    else
      @status = 'bad'
    end
    @client.send(Presence.new.set_type(:available))

    send
  end

  def send
    # get_connect
    message = Message.new(@jabber_id, "I am login")
    message.type=:chat
    @client.send(message)
  end

  def return_message
    @client.add_message_callback do |message|
      unless message.body.nil? && message.type != :error
        puts "Received message: #{message.body}"
        reply = Message.new(message.from, message.body)
        reply.type = message.type
        @client.send(reply)
      end
    end
  end

  def switch_return_message
    # mainthread = Thread.current
    @client.add_message_callback do |message|
      unless message.body.nil? && message.type != :error
        reply = case message.body
          when "time" then reply(message, "Current time is #{Time.now}")
          when "help" then reply(message, "Available commands are: 'Time', 'Help'.")
          else reply(message, "You said: #{message.body}")
        end
      end
    end
    # Thread.stop
    # @client.close

    sleep(100)
  end


  def reply message, reply_content
    reply_message = Message.new(message.from, reply_content)
    reply_message.type = message.type
    @client.send reply_message
  end

end
