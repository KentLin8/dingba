class HomeController < ApplicationController
  layout 'home'
  before_action :get_user, :only => [:index, :booking_restaurant, :get_condition, :save_booking, :notice_friend, :cancel_booking, :save_cancel_booking]
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

    @restaurant = Restaurant.new
    @restaurant = Home.get_restaurant(restaurant_url)
    @booking_condition = BookingCondition.new
    if !@restaurant.blank?
      @booking_condition = BookingCondition.new
      @booking_condition = Home.get_condition(@restaurant, booking_day)
    else
      redirect_to home_path
    end
  end

  def get_condition
    restaurant_url = params[:id]
    @booking_day = params[:booking_day]

    @restaurant = Restaurant.new
    @restaurant = Home.get_restaurant(restaurant_url)
    @booking_condition = BookingCondition.new
    if !@restaurant.blank?
      @booking_condition = BookingCondition.new
      @booking_condition = Home.get_condition(@restaurant, @booking_day)

      result = {:success => true, :attachmentPartial => render_to_string('home/_booking_zone', :layout => false, :locals => { :booking_condition => @booking_condition, :booking_day => @booking_day, :restaurant => @restaurant, :booker => @booker })}
      render json: result
    else
      render json: {:error => true, :message => '沒有此家餐廳!'}
    end
  end

  def save_booking
    result = Home.save_booking(@booker, params[:booking])

    #result = {:success => true, :attachmentPartial => render_to_string('home/_booking_zone', :layout => false, :locals => { :booking_condition => @booking_condition, :booking_day => @booking_day, :restaurant => @restaurant, :booker => @booker })}
    render json: result
  end

  def notice_friend
    begin
      booking_id = params[:booking_id].to_i
      notice_emails = params[:notice_emails].strip

      if booking_id.blank? || notice_emails.blank?
        render json: {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
      end

      result = MyMailer.notify_friend(notice_emails, booking_id).deliver

      if result.perform_deliveries
        render json: {:success => true, :data => '通知成功!' }
      else
        render json: {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
      end

    rescue => e
      render json: {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
    end
  end

  def cancel_booking
    begin
      #@booking = Booking.find(1)
      @booking = Booking.find(params[:booking_id].to_i)
      @restaurant = Restaurant.find(@booking.restaurant_id)
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb ,Action:cancel_booking"
      render json: {:error => true, :message => '阿! 發生錯誤了! 資料異常!'}
    end
  end

  def save_cancel_booking
    result = RestaurantManage.cancel_booking(params[:booking_id], params[:status], params[:cancel_note])
    render json: result
  end

  def get_user
    begin
      @booker = User.new
      if !current_user.blank?
        if current_user.role == '0'   # restaurant
          #signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
          #redirect_to confirmation_getting_started_path
        elsif current_user.role == '1'  # booker
          @booker = User.find(current_user.id)
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/home_controller.rb  ,Filter:get_user"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      redirect_to home_path
    end
  end

end
