class Api::User::ConfirmationsController < Api::Base

  def create
    user = Api::User.find_by(email: valid_params[:email])
    return render json: { error_code: '001', description: 'E-mail not found' }, :status => 400 if user.nil?
    return render json: { error_code: '006', description: 'the user has been confirmed.' }, :status => 400 if user.confirmed?

    user = User.send_confirmation_instructions(email: valid_params[:email], 'Content-Transfer-Encoding' => 'UTF-8')
    return render json: {result: 'success'} if user.errors.empty?
    render json: {error_code: "000", description: 'E-mail ' + user.errors[:email].first}, :status => 400
  end

  private
    def valid_params
      params.permit(:email)
    end
end
