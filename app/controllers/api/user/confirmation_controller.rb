class Api::User::ConfirmationController < ApplicationController
  def create

  	user = User.send_confirmation_instructions(email: valid_params[:email])
  	return render json: {result: 'success'} if user.errors.empty?
  	render json: {code: 001, description: 'E-mail not found.'}
  end

  private 
    def valid_params
      params.permit(:email)
    end
end
