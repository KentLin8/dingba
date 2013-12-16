class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ## override devise
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || sign_in_with_cus(resource_or_scope)
  end

  def sign_in_with_cus(user)
    begin
      if user.role == '0'
        restaurant_users = RestaurantUser.where(:user_id => user.id) # TODO select restaurant
        restaurant = Restaurant.find(restaurant_users.first.restaurant_id)

        if RestaurantManage.check_restaurant_info(restaurant)
          if RestaurantManage.check_supply_condition(restaurant.id)
            '/restaurant#/calendar/restaurant_month'
          else
            '/restaurant#/restaurant_manage/supply_condition'
          end
        else
          confirmation_getting_started_path
        end
      else
        booker_manage_index_path
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/application_controller.rb  ,Method:sign_in_with_cus(user)"
      home_path
    end

    ## origin code
    #scope = Devise::Mapping.find_scope!(resource_or_scope)
    #home_path = "#{scope}_root_path"
    #if respond_to?(home_path, true)
    #  send(home_path)
    #elsif respond_to?(:root_path)
    #  root_path
    #else
    #  "/"
    #end
    ## origin code end
  end

end
