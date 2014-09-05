class User < ActiveRecord::Base
  enum gender: {male: 1, female: 2}
  before_create :add_default_display_name
  has_many :identity
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable, :omniauthable

  validates_acceptance_of :agreement, :allow_nil => false,
  :acceptance => true, :on => :create

  SOCIALS = {
    facebook: 'Facebook',
    google_oauth2: 'Google'
  }

  def self.from_omniauth(auth)
    Identity.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
  end


  def self.sign_up_omniauth(auth, current_user, agreement)
    identity = Identity.where(provider: auth["provider"], uid: auth["uid"].to_s).first_or_initialize

    if identity.user.blank?
      user = current_user.nil? ? User.where('email = ?', auth["info"]["email"]).first : current_user
      if user.blank?
        user = User.new
        user.skip_confirmation!
        user.password = Devise.friendly_token[0, 20]
        user.fetch_details(auth)
        user.edm_accept = 0
        user.agreement = agreement
        user.save
      end
      identity.user = user
      identity.save
    end
    identity
  end

  def fetch_details(auth)
    self.first_name = auth["info"]["first_name"]
    self.last_name = auth["info"]["last_name"]
    self.display_name = auth["info"]["name"]
    self.email = auth["info"]["email"]
    self.middle_name = auth["extra"]["raw_info"]["middle_name"] if auth["extra"]["raw_info"]["middle_name"]
    self.language = auth["extra"]["raw_info"]["locale"]
    self.gender = auth["extra"]["raw_info"]["gender"]
  end

  private
    def add_default_display_name
      if self.display_name.blank?
        display_name = " "
        display_name.insert(0, self.first_name) if self.first_name
        display_name << self.middle_name if self.middle_name
        display_name.strip!
        self.display_name = display_name
      end
    end
end
