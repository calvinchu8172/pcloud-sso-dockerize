class Api::Invitation::Permission < AcceptedUser
	include ActiveModel::Validations
	attr_accessor :certificate, :signature, :device_account, :cloud_id

 	def initializer
 		validates_with SslValidator, signature_key: [:device_account, :cloud_id]
 	end
	# def check_destroy
	# 	validates_with SslValidator, signature_key: [:device_account, :cloud_id]
	# 	return false unless self.errors.blank?
	# end
end