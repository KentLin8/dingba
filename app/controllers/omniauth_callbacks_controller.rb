class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def passthru
    send(params[:provider]) if providers.include?(params[:provider])
  end

  def facebook
    begin
      @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

      if @user.blank?
        flash.now[:alert] = 'facebook params error'
        redirect_to home_path
      end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication
      else
        redirect_to home_path
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/omniauth_callbacks_controller.rb  ,Method:facebook"
    end
  end

  def google_oauth2
    begin
      @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

      if @user.blank?
        flash.now[:alert] = 'google params error'
        redirect_to home_path
      end

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication
      else
        redirect_to home_path
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/omniauth_callbacks_controller.rb  ,Method:google_oauth2"
    end
  end

  private

  def providers
    ['facebook', 'google_oauth2']
  end
end