class User < ActiveRecord::Base
  # http://sourcey.com/rails-4-omniauth-using-devise-with-twitter-facebook-and-linkedin/
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:twitter]


  has_many :friends

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        location = auth.info.location
        user_location = Geocoder.coordinates("#{location}")
        user = User.new(
          name: auth.extra.raw_info.name,
          #username: auth.info.nickname || auth.uid,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20],

          # user.provider = auth["provider"]
          # user.uid = auth["uid"]
          twitter_name: auth.info.name,
          twitter_address: auth.info.location,
          twitter_avatar: auth.info.image,
          twitter_oauth_token: auth.credentials.token,
          twitter_oauth_secret: auth.credentials.secret,

          twitter_latitude: user_location.first,
          twitter_latitude: user_location.second

        )
        user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  #acts_as_taggable_on :skills
  enum role: [:user, :vip, :admin]
  after_initialize :set_default_role, :if => :new_record?

  # token authentication https://github.com/gonzalo-bulnes/simple_token_authentication
  acts_as_token_authenticatable


  has_attached_file :avatar, 
    styles: {
      thumb: '75x75#', #iphone thumbnail
      web: '300x300#', #web index pages
    },
    convert_options: {
      thumb: '-quality 75 -strip',
      web: '-quality 75 -strip',
    }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  #has_many :devices

  #before_destroy :remove_user_from_mailchimp

  # validates_format_of :name, :with => /\A[a-zA-Z0-9_]{2,30}\Z/
  # validates :name, presence: true,
  #                  uniqueness: { case_sensitive: false }


  #has_many :meetings,  :foreign_key => 'creator_id'
  # belongs to account
  # has many messages
  # has many patients?

  # http://rails-bestpractices.com/posts/4-add-model-virtual-attribute
  def full_name
    [first_name, last_name].join(' ')
  end

  def full_name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def avatar_url
      avatar.url(:thumb)
  end

  def self.all_except(user)
    where.not(id: user)
  end

  def set_default_role
    self.role ||= :user
  end

  # Override Devise::Confirmable#after_confirmation
  def after_confirmation
    #add_user_to_mailchimp
  end

  # wildcard string match on name field with 3 chars or more
  def self.search(search)
    if search and search.length > 2
      wildcard_search = "%#{search}%"

      where("name ILIKE :search", search: wildcard_search).take(5)
    end
  end

  # override Devise method
  # no password is required when the account is created; validate password when the user sets one
  validates_confirmation_of :password
  def password_required?
    if !persisted?
      !(password != "")
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  private

  def add_user_to_mailchimp
    mailchimp = Gibbon::API.new
    result = mailchimp.lists.subscribe({
      :id => ENV['MAILCHIMP_LIST_ID'],
      :email => {:email => self.email},
      :double_optin => false,
      :update_existing => true,
      :send_welcome => true
    })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  rescue Gibbon::MailChimpError => e
    Rails.logger.info("MailChimp subscribe failed for #{self.email}: " + e.message)
  end


  def remove_user_from_mailchimp
    mailchimp = Gibbon::API.new
    result = mailchimp.lists.unsubscribe({
      :id => ENV['MAILCHIMP_LIST_ID'],
      :email => {:email => self.email},
      :delete_member => true,
      :send_goodbye => false,
      :send_notify => true
      })
    Rails.logger.info("Unsubscribed #{self.email} from MailChimp") if result
  rescue Gibbon::MailChimpError => e
    Rails.logger.info("MailChimp unsubscribe failed for #{self.email}: " + e.message)
  end



end