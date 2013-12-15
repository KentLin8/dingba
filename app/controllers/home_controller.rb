class HomeController < ApplicationController
  layout 'home'
  before_action :get_user, :only => [:booking_restaurant, :get_condition, :save_booking]
  #before_action :get_restaurant, :only => [:booking_restaurant]

  # =========================================================================
  # panda: 我比較偏向不使用path,因為命名這件事讓trace code變得麻煩一點(must see routes),雖然path可以讓rename 好管理,但基本上!! rename畢竟是很少發生的情況
  # flash.now[:alert] = result
  # render no stop the process, must add return
  # booking status 0 = 已訂位
  # booking status 1 = 已用餐
  # booking status 2 = 同伴無法配合
  # booking status 3 = 餐廳當天座位不夠
  # booking status 4 = 選擇了其他餐廳
  # booking status 5 = 餐廳臨時公休
  # booking status 6 = 聚餐延期
  # booking status 7 = 其他
  # =========================================================================

  def index
    #主要首頁,p1 不開放
  end

  # GET the booking url ,when restaurant 2000 ,build home page, and move booking page to this place
  def booking_restaurant
    restaurant_url = params[:id]
    booking_day = params[:booking_day]

    length = restaurant_url.length
    restaurant_url = restaurant_url.to_i
    if restaurant_url.to_s.length == length
      @restaurant = Home.get_restaurant(restaurant_url)
      if !@restaurant.blank?
        @booking_condition = Home.get_condition(@restaurant, booking_day)
      end
    end
  end

  def get_condition
    restaurant_url = params[:id]
    booking_day = params[:booking_day]

    length = restaurant_url.length
    restaurant_url = restaurant_url.to_i
    if restaurant_url.to_s.length == length
      @restaurant = Home.get_restaurant(restaurant_url)
      if !@restaurant.blank?
        @booking_condition = Home.get_condition(@restaurant, booking_day)

        result = {:success => true, :attachmentPartial => render_to_string('home/booking_zone', :layout => false, :locals => { :booking_condition => @booking_condition })}
        render json: result
      end
    end
  end

  def save_booking
    #restaurant_id =  params[:restaurant_id]
    #booking_time = params[:booking_time]
    #num_of_people = params[:num_of_people]
    #booker_name = params[:booker_name]
    #booker_phone = params[:booker_phone]
    #booker_email = params[:booker_email]
    #booker_remark = params[:booker_remark]

    result = Home.save_booking(@booker, params[:booking])
    render json: result
  end

  def notice_friend
    params[:booking_id]
    params[:email]

    if params[:booking_id].blank? || params[:email].blank?
      return {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
    end

    MyMailer.notify_friend(params[:email], params[:booking_id]).deliver
  end

  def cancel_booking
    begin
      #@booking = Booking.find(1)
      @booking = Booking.find(params[:booking_id].toi)
      @restaurant = Restaurant.find(@booking.restaurant_id)
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb ,Action:cancel_booking"
      return {:error => true, :message => '阿! 發生錯誤了! 資料異常!'}
    end
  end

  def save_cancel_booking
    result = RestaurantManage.cancel_booking(params[:booking])
    render json: result
  end

  def get_user
    begin
      if !current_user.blank?
        if current_user.role == '0'   # restaurant
          manage_restaurants = RestaurantUser.where(:user_id => current_user.id)
          if !manage_restaurants.blank?         # system error
            target = manage_restaurants.first   # let user choose restaurant to mange, in phase 2
          end

        elsif current_user.role == '1'  # booker
          @booker = current_user
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb  ,Filter:get_user"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      redirect_to home_path
    end
  end

end
