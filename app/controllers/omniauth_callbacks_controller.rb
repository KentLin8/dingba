class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def passthru
    send(params[:provider]) if providers.include?(params[:provider])
  end

  def facebook

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    flash.now[:alert] = request.env['omniauth.auth']
    render res_new_path
    return
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.blank?
      flash.now[:alert] = 'facebook params error'
      render res_new_path
    end

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      render res_new_path
    end
  end

  def google_oauth2
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      render res_new_path
    end
  end

  private

  def providers
    ['facebook', 'google_oauth2']
  end
end