class User < ActiveRecord::Base
  OUT_OF_LENGTH = '資料長度超過限制'
  NOT_EMPTY = '不能空白'
  validates :email, :presence => { :message => "E-Mail，" + NOT_EMPTY } ,
                    :format => { with: /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/, :message => "E-mail 格式錯誤喔!" },
                    :length => { :maximum => 255, :message => "E-Mail，" + OUT_OF_LENGTH }
  validates :name, :presence => { :message => "姓名，" + NOT_EMPTY } ,
                   :length => { :maximum => 20, :message => "姓名，" + OUT_OF_LENGTH }
  validates :role, #:presence => { :message => "角色標記，" + NOT_EMPTY } ,
                   :length => { :maximum => 1, :message => "角色標記，" + OUT_OF_LENGTH }
  validates :phone, #:presence => { :message => "電話，" + NOT_EMPTY } ,
                    :length => { :maximum => 30, :message => "電話，" + OUT_OF_LENGTH }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :yahoo]

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    if auth.blank?
      return nil
    end
    user = User.where(:email => auth.info.email).first
    unless user
      user = User.new(name:auth.extra.raw_info.name,
                      provider:auth.provider,
                      #uid:auth.uid,
                      email:auth.info.email,
                      password:Devise.friendly_token[0,20],
                      role: '1')

      #user.skip_confirmation_notification!
      user.skip_confirmation!
      user.save
      user.send_confirmation_instructions
    end
    user
  end

  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    if access_token.blank?
      return nil
    end
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.new(name: data["name"],
                      email: data["email"],
                      provider: "google",
                      password: Devise.friendly_token[0,20],
                      role: '1')

      #user.skip_confirmation_notification!
      user.skip_confirmation!
      user.save
      user.send_confirmation_instructions
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

end
