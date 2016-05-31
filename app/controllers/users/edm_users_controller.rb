class Users::EdmUsersController < ApplicationController

  before_action :authenticate_user!
  before_action :admin_auth!

  def index
  end

  def download_csv
    users = User.order(:id)
    attributes = ["id", "email", "edm_accept", "language", "country", "sign_on_by"]

    csv_string = CSV.generate do |csv|
      csv << attributes
      users.each do |user|
        csv << [
          user.id,
          user.email,
          user.edm_accept,
          user.language,
          user.country,
          check_sign_on_by(user)
        ]
      end
    end

    send_data(csv_string, filename: filename, type: 'text/csv; charset=utf-8')
  end

  private

    def filename
      "EDM-Users-List-#{Time.now.strftime("%Y%m%d%H%M%S")}.csv"
    end

    def check_sign_on_by(user)
      if user.confirmation_token && user.confirmed_at
        method = 'email'
      else
        method = ''
      end

      if !user.identity.find_by_provider('facebook').blank?
        if method == ''
          method += 'facebook'
        else
          method += '/facebook'
        end
      end

      if !user.identity.find_by_provider('google_oauth2').blank?
        if method == ''
          method += 'google_oauth2'
        else
          method += '/google_oauth2'
        end
      end

      method
    end

    def admin_auth!
      redis_id = Redis::HashKey.new("admin:" + current_user.id.to_s + ":session")

      unless redis_id['name'] == current_user.email
        redirect_to :root
      end

      if redis_id['auth'].nil? || !redis_id['auth'].include?("download_edm_users")
        redirect_to :root
      end

    end

end
