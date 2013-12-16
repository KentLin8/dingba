
class RestaurantManageController < ApplicationController
  layout 'restaurant_manage'
  before_action :get_restaurant, :only => [:restaurant, :restaurant_info, :restaurant_info_save, :restaurant_image, :upload_img, :image_cover_save, :image_destroy,
                                           :supply_condition, :supply_time, :supply_condition_save, :condition_state_save,
                                           :destroy_condition, :special_create, :day_booking, :query_books_by_date,
                                           :modify_booking, :modify_booking_save, :cancel_booking]


  # =========================================================================
  # TODO: check again function:get_restaurant() in the usages action
  # =========================================================================

  # GET
  def restaurant
  end

  # ====== Code Check: 2013/12/07 ====== [ panda ok ]
  # ====== Code Check: 2013/12/09 ====== [ kent: TODO: to fix something ]
  # GET ==== Function: show restaurant information view
  # =========================================================================
  def restaurant_info
    render 'restaurant_manage/restaurant_info', :layout => false
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: wait for res.pay_type ]
  # POST === Function: save restaurant information
  # =========================================================================
  def restaurant_info_save
    result = RestaurantManage.restaurant_info_save(params[:restaurant])
    get_restaurant()
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show upload restaurant images view
  # =========================================================================
  def restaurant_image
    render 'restaurant_manage/restaurant_image', :layout => false
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: 1.no file path no alert message, 2.alert too much ex: two img will alert success twice]
  # POST === Function: upload restaurant images
  # =========================================================================
  def upload_img
    result = RestaurantManage.upload_img(@restaurant, params[:qqfile], request.body.read)
    get_restaurant()
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: wait Front-end engineering ]
  # GET ==== Function: save the image which is front cover
  # =========================================================================
  def image_cover_save
    result = RestaurantManage.image_cover_save(@restaurant, params[:cover_id])
    get_restaurant()
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: wait Front-end engineering ]
  # GET ==== Function: destroy select image
  # =========================================================================
  def image_destroy
    result = RestaurantManage.image_destroy(@restaurant, params[:pic_id])
    get_restaurant()
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show supply condition view
  # =========================================================================
  def supply_condition
    @conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    if @conditions.blank?
      redirect_to res_manage_supply_time_path
    else
      render 'restaurant_manage/supply_condition', :layout => false
    end
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show supply time view
  # =========================================================================
  def supply_time
    condition_id = params[:condition_id]
    begin
      @time_zones = RestaurantManage.get_time_zones(condition_id)
      if !condition_id.blank?
        @supply_time = SupplyCondition.find(condition_id.to_i)
      end
    rescue => e
      # in this condition is that user change the condition_id
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Action:supply_time"
      @time_zones = RestaurantManage.get_time_zones(nil)
    end
    render 'restaurant_manage/supply_time', :layout => false
  end

  # ====== Code Check: 2013/12/08 ====== [ panda: ok ]
  # POST === Function: save supply condition
  # =========================================================================
  def supply_condition_save
    condition = params[:condition]
    zones = []
    zones.push(params[:zone0])
    zones.push(params[:zone1])
    zones.push(params[:zone2])
    zones.push(params[:zone3])
    zones.push(params[:zone4])
    zones.push(params[:zone5])

    if condition[:id].blank?
      result = RestaurantManage.supply_condition_create(@restaurant.id, condition, zones)
    else
      result = RestaurantManage.supply_condition_update(@restaurant.id, condition, zones)
    end

    @conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :conditions => @conditions })
    render json: result
  end

  # ====== Code Check: 2013/12/08 ====== [ panda: ok ]
  # POST === Function: save condition state
  # =========================================================================
  def condition_state_save
    data = request.raw_post
    @conditions = RestaurantManage.condition_state_save(data, @restaurant)
    if @conditions.blank?
      render json: {:error => true, :message => '阿! 發生錯誤了!'}
    else
      get_restaurant()
      render json: {:success => true, :data => '設定成功!'}
    end
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: if no any condition ,choice redirect to supply_condition, or keep this code ]
  # GET ==== Function: destroy condition
  # =========================================================================
  def destroy_condition
    result = RestaurantManage.destroy_condition(params[:condition_id])
    @conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :conditions => @conditions })
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show special time view
  # =========================================================================
  def special_time
    @special_day = params[:special_day]
    @time_zones = RestaurantManage.get_time_zones(params[:condition_id])
    render 'restaurant_manage/_time_zones', :layout => false
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # POST === Function: save special condition
  # =========================================================================
  def special_create
    zones = []
    zones.push(params[:zone0])
    zones.push(params[:zone1])
    zones.push(params[:zone2])
    zones.push(params[:zone3])
    zones.push(params[:zone4])
    zones.push(params[:zone5])

    result =  RestaurantManage.special_create(zones, params[:special_day], @restaurant.id)
    @conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :conditions => @conditions })
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show day booking view
  # =========================================================================
  def day_booking
    @zones_books = RestaurantManage.get_day_books(@restaurant.id, params[:special_day])
    render 'restaurant_manage/_day_booking', :layout => false
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show booking report view
  # =========================================================================
  def query_books_by_date
    @from, @to = params[:from], params[:to]
    if @from.blank? || @to.blank?
      now = Time.now
      @from = now.beginning_of_month.to_date.to_s
      @to = now.end_of_month.to_date.to_s
    end
    #@books = RestaurantManage.query_books_by_date(@restaurant.id, params[:range_begin], params[:range_end])
    @books = RestaurantManage.query_books_by_date(@restaurant.id, @from, @to)
    render 'restaurant_manage/_booking_report', :layout => false
  end

  # ====== Code Check: 2013/12/08 ====== [ panda: TODO: wait Front-end engineering ]
  # GET ==== Function: show modify booking view
  # =========================================================================
  def modify_booking
    begin
      @booking = Booking.find(params[:booking_id].to_i)
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Action:modify_booking"
    end

    render 'restaurant_manage/_modify_booking'#, :layout => false
  end

  # ====== Code Check: 2013/12/08 ====== [ panda: TODO: wait Front-end engineering ]
  # POST === Function: save modify booking
  # =========================================================================
  def modify_booking_save
    result = RestaurantManage.modify_booking_save(params[:booking])
    render json: result
  end

  # ====== Code Check: 2013/12/08 ====== [ panda: TODO: wait Front-end engineering ]
  # POST === Function: cancel booking
  # =========================================================================
  def cancel_booking
    result = RestaurantManage.cancel_booking(params[:booking])
    render json: result
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: think the auth solution ]
  # func ==== Function: auth user and get restaurant
  # =========================================================================
  def get_restaurant
    begin
      if current_user.blank?
        flash.now[:alert] = '您還沒登入喔!~~ '
        redirect_to home_path
      else
        manage_restaurants = RestaurantUser.where(:user_id => current_user.id)
        if !manage_restaurants.blank?         # system error
          target = manage_restaurants.first   # let user choose restaurant to mange, in phase 2

          @restaurant = Restaurant.find(target.restaurant_id)
          @res_url = APP_CONFIG['domain'] + @restaurant.res_url.to_s
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Filter:get_restaurant"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      redirect_to home_path
    end
  end

  # test action
  def book_create

    b = Booking.new
    b.user_id = 1
    b.restaurant_id = 1
    b.time_zone_id = 43
    b.booking_time = '2013-12-25 12:00'
    b.name = 'kent'
    b.email = 'kent@gmail.com'
    b.num_of_people = 1
    b.save

    b = Booking.new
    b.user_id = 1
    b.restaurant_id = 1
    b.time_zone_id = 43
    b.booking_time = '2013-12-25 13:00'
    b.name = 'rae'
    b.email = 'rae@gmail.com'
    b.num_of_people = 3
    b.save

    b = Booking.new
    b.user_id = 1
    b.restaurant_id = 1
    b.time_zone_id = 44
    b.booking_time = '2013-12-25 18:00'
    b.name = 'rae'
    b.email = 'rae@gmail.com'
    b.num_of_people = 4
    b.save

    b = Booking.new
    b.user_id = 1
    b.restaurant_id = 1
    b.time_zone_id = 44
    b.booking_time = '2013-12-25 19:00'
    b.name = 'panda'
    b.email = 'panda@gmail.com'
    b.num_of_people = 2
    b.save

    db = DayBooking.new
    db.restaurant_id = 1
    db.day = '2013-12-25'
    db.zone1 = 2
    db.zone2 = 2
    db.save
  end

end
