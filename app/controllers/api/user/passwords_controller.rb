class Api::User::PasswordsController < Api::Base
  def create
    user = User.send_reset_password_instructions(email: valid_params[:email])

  	return render json: {result: 'success'} if user.errors.empty?

  	render json: {error_code: "001", description: 'E-mail not found.'}, :status => 400
  end

  private
    def valid_params
      params.permit(:email)
    end
end
