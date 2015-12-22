class Api::Healthy::StatusController < Api::Base

	def show
		render :json => {'message' => 'OK'}, status: 200
	end

end