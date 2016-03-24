class Api::Healthy::StatusController < Api::Base

	def show
		render :json => {'message' => 'OK', "version" => "#{Version['version']}"}, status: 200
	end

end