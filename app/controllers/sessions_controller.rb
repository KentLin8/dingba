class SessionsController < Devise::SessionsController
  #layout 'restaurant_manage'
  layout 'registration'

  def restaurant_new
    new(sign_in_params, '0')
  end

  def booker_new
    #@res_url = params[:format]
    #@res_url = @res_url[0..5]

    new(sign_in_params, '1')
  end

  def new(sign_in_params, role)
    begin
      if !current_user.blank?
        if current_user.role == '0'
          restaurant_users = RestaurantUser.where(:user_id => current_user.id)
          restaurant = Restaurant.find(restaurant_users.first.restaurant_id)

          if RestaurantManage.check_restaurant_info(restaurant)
            if RestaurantManage.check_supply_condition(restaurant.id)
              redirect_to '/restaurant#/calendar/restaurant_month'
            else
              redirect_to '/restaurant#/restaurant_manage/supply_condition'
            end
          else
            redirect_to confirmation_getting_started_path
          end
        else
          redirect_to booker_manage_index_path
        end
      else
        self.resource = resource_class.new(sign_in_params)
        clean_up_passwords(resource)
        respond_with(resource, serialize_options(resource))
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/sessions_controller.rb  ,Method:new(sign_in_params)"
      #if role == '0'
      #  redirect_to res_session_new_path
      #else
      #  redirect_to booker_session_new_path
      #end
    end
  end

  # POST /resource/sign_in
  def create
    user = params[:user]

    begin
      target_user = User.where(:email => user[:email])

      if target_user.blank?
        #flash.now[:alert] = '沒有此E-Mail 資料!'

        if user[:role] == '0'
          redirect_to res_session_new_path
          #render 'devise/sessions/restaurant_new'
        elsif user[:role] == '1'
          redirect_to booker_session_new_path
          #render 'devise/sessions/booker_new'
        end
        return
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/sessions_controller.rb  ,Action:create"
      redirect_to home_path
      return
    end

    self.resource = warden.authenticate!(auth_options)

    if is_flashing_format?
      set_flash_message(:notice, :signed_in)
    end

    sign_in(resource_name, resource)
    yield resource if block_given?
    redirect_to after_sign_in_path_for(resource)
    #respond_with resource, :location => after_sign_in_path_for(resource)
  end

end