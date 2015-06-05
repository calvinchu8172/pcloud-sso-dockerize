class Api::Resource::PermissionsController < Api::Base
	skip_before_filter :verify_authenticity_token
	before_filter :validate_delete_permission_params

	def delete
		user = User.find_by_encrypted_id(valid_params[:cloud_id])
		return render :json => { error_code: "012", description: "invalid cloud id or token." }, status: 400 if user.blank?
		permissions = Api::Resource::Permission.where(user_id: user.id)
		permissions.each do |permission|
			xmpp_user = XmppUser.find_by(username: valid_params[:device_account])
			next if xmpp_user.blank?
			permission.destroy if permission.invitation.device.id == xmpp_user.session.to_i
		end
		render :json => { "result" => "success" }, status: 200
	end

	def validate_delete_permission_params
		permission = Api::Resource::Permission.new valid_params
	    unless permission.valid?
	      	{ "004" => "device_account",
	      	  "012" => "cloud_id",
	      	  "013" => "certificate",
	      	  "014" => "signature" }.each { |error_code, field| return render :json =>  { error_code: error_code, description: permission.errors[field].first } unless permission.errors[field].empty? }
		end
	end

	private
		def valid_params
    	params.permit(:certificate, :signature, :device_account, :cloud_id)
  	end
end