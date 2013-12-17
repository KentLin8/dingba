class SessionsController < Devise::SessionsController
  layout 'restaurant_manage'

  def restaurant_new
    new(sign_in_params)
  end

  def booker_new
    new(sign_in_params)
  end

  def new(sign_in_params)

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
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    redirect_to after_sign_in_path_for(resource)
    #respond_with resource, :location => after_sign_in_path_for(resource)
  end

end