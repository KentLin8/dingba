class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from User::Exception, :with => :show_error
  #helper_method :current_user

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

  #protected

  #def current_user=(user)
    #return unless session[:user_id]
    #@current_user ||= User.find_by_id(session[:user_id])
    #@current_user = user
  #end

  def show_error(exception)
    begin
      self.resource = resource_class.new
      clean_up_passwords(resource)

      if !current_user.blank?
        if current_user.role == '0'
          flash.now[:alert] = '重新登入警告！為保安全，我們將您登入狀態清除，請再次登入，謝謝'
          render 'devise/sessions/restaurant_new'
        elsif current_user.role == '1'
          flash.now[:alert] = '重新登入警告！為保安全，我們將您登入狀態清除，請再次登入，謝謝'
          render 'devise/sessions/booker_new'
        end
        return
      else
        redirect_to home_path
      end
    rescue => e
      flash.now[:alert] = '發生未知的錯誤，請與CoDream團隊聯絡，謝謝'
      redirect_to home_path
    end
  end

end
