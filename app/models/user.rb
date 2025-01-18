class User < ApplicationRecord
  has_secure_password

  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :sessions, dependent: :destroy
  has_many :recovery_codes, dependent: :destroy
  has_many :sign_in_tokens, dependent: :destroy
  has_many :auth_events, dependent: :destroy

  validates :first_name, presence: true

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, confirmation: true, allow_nil: true, length: { in: 5..64 },
            format: {
              with: /\A(?=.*[A-Z])(?=.*[\W]).+\z/,
              message: 'must contain at least one uppercase letter and one symbol'
            }

  normalizes :email, with: -> { _1.strip.downcase }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  before_validation on: :create do
    self.otp_secret = ROTP::Base32.random
  end

  after_update if: :password_digest_previously_changed? do
    sessions.where.not(id: Current.session).delete_all
  end

  after_update if: :email_previously_changed? do
    auth_events.create! action: "email_verification_requested"
  end

  after_update if: :password_digest_previously_changed? do
    auth_events.create! action: "password_changed"
  end

  after_update if: [:verified_previously_changed?, :verified?] do
    auth_events.create! action: "email_verified"
  end
end
