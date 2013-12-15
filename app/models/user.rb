class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :yahoo]

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.new(name:auth.extra.raw_info.name,
                      provider:auth.provider,
                      uid:auth.uid,
                      email:auth.info.email,
                      password:Devise.friendly_token[0,20]
                      )

      user.skip_confirmation!
      user.save!

    end
    user
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.new(name: data["name"],
                      email: data["email"],
                      provider: "google",
                      password: Devise.friendly_token[0,20])

      user.skip_confirmation!
      user.save!
    end
    user
  end

  #def self.find_for_yahoo(access_token, signed_in_resource=nil)
  #  data = access_token.info
  #  user = User.where(:email => data["email"]).first
  #
  #  unless user
  #    user = User.new(name: data["name"],
  #                    email: data["email"],
  #                    provider: "yahoo",
  #                    password: Devise.friendly_token[0,20])
  #
  #    user.skip_confirmation!
  #    user.save!
  #  end
  #  user
  #end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end


end
