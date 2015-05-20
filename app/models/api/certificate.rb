class Api::Certificate
  
  def self.init 
  	@@public_key_list = {}
    ENV.each do |key, value|
    	if key.start_with?('PERSONAL_CLOUD_CERTIFICATE_')
    		begin
    		  certificate_item = OpenSSL::X509::Certificate.new(value)
    	    @@public_key_list[certificate_item.serial] = certificate_item.public_key
  	    rescue; end
    	end
    end
    @@public_key_list
  end

  def self.public_key_list
  	@@public_key_list ||= init
  end
end