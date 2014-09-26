class User < ActiveRecord::Base
  enum gender: {male: 1, female: 2}
  before_create :add_default_display_name
  has_many :identity

  validates_length_of :email, :first_name, :middle_name, :last_name, :mobile_number, maximum:255
  validates_length_of :password, in: 8..14
  validates_length_of :mobile_number, maximum: 40

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :timeoutable, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

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
        user.password = Devise.friendly_token[0, 14]
        user.fetch_details(auth)
        user.edm_accept = 0
        user.agreement = agreement
        user.save!
      end
      identity.user = user
      identity.save!
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
    self.gender = auth["extra"]["raw_info"]["gender"] if auth["extra"]["raw_info"]["gender"] && auth["extra"]["raw_info"]["gender"] != "other"
  end

  def change_locale!(new_locale)
    new_locale = new_locale.to_s
    if self.language != new_locale
      self.language = new_locale
      # self.save
    end
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
