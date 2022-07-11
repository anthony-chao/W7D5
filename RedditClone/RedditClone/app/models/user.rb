class User < ApplicationRecord

    has_many :posts,
        foreign_key: :author_id,
        class_name: :Post

    has_many :subs,
        foreign_key: :moderator_id,
        class_name: :Sub

    validates :username, presence: true, uniqueness: true
    validates :password_digest, presence: true
    validates :password, length: { minimum: 6 }
    validates :session_token, presence: true, uniqueness: true

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)

        if user && user.is_password?(password)
            user
        else
            nil
        end
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def generate_session_token
        SecureRandom::urlsafe_base64
    end

    attr_reader :password
    after_initialize :ensure_session_token

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def ensure_session_token
        self.session_token ||= generate_session_token
    end

    def reset_session_token!
        self.session_token = generate_session_token
        self.save!
        self.session_token
    end
end
