module OauthFlow
  extend ActiveSupport::Concern

	included do

		before_action :set_oauth_flow_flag

		def set_oauth_flow_flag
			if current_user
				if request.path.match("/oauth")
					warden.session['in_oauth_flow'] = Time.now.to_i
				end
			end
		end

		
	end

end