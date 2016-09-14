module ExceptionHandler
	extend ActiveSupport::Concern

	included do 
		rescue_from Warden::NotAuthenticated, with: :deny_access
	end

	private
		def deny_access
			redirect_to :unauthenticated_root
		end
end