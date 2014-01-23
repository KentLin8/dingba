
class RestaurantManageController < ApplicationController
  layout 'restaurant_manage'
  before_action :get_restaurant, :only => [:restaurant, :restaurant_info, :restaurant_info_save, :restaurant_image, :upload_img, :image_cover_save, :image_destroy,
                                           :supply_condition, :supply_time, :supply_condition_save, :condition_state_save,
                                           :destroy_condition, :special_create, :day_booking, :query_books_by_date,
                                           :modify_booking, :modify_booking_save, :cancel_booking,:cancel_booking_save, :adm_list_all ]


  # =========================================================================
  # TODO: check again function:get_restaurant() in the usages action
  # =========================================================================

  # GET
  def restaurant
  end

  # GET ==== Function: show restaurant information view
  def restaurant_info
    render json: {:success => true, :attachmentPartial => render_to_string('restaurant_manage/restaurant_info', :layout => false ) }
  end

  # POST === Function: save restaurant information
  def restaurant_info_save
    result = RestaurantManage.restaurant_info_save(params[:restaurant])
    get_restaurant()

    if result[:success] && !@restaurant.front_cover.blank?
      conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')

      if conditions.blank?
        @supply_time = SupplyCondition.new
        @supply_time.available_week = '0,1,2,3,4,5,6'
        @supply_time.is_special = 'f'
        @time_zones = RestaurantManage.get_time_zones(nil)
        result[:attachmentPartial] = render_to_string('restaurant_manage/supply_time', :layout => false, :locals => {:supply_time => @supply_time, :time_zones => @time_zones})
        result[:step] = '2-1'
        result[:url] = '/restaurant_manage/supply_time'
      elsif conditions.count > 0
        @special_conditions = conditions.select { |x| x.is_special == 't' }
        @normal_conditions = conditions.select { |x| x.is_special != 't' }
        result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :special_conditions => @special_conditions, :normal_conditions => @normal_conditions})
        result[:step] = '2-1'
        result[:url] = '/restaurant_manage/supply_condition'
      end
    else
      result[:attachmentPartial] = render_to_string('restaurant_manage/restaurant_image', :layout => false, :locals => { :restaurant => @restaurant})
      result[:step] = '2'
      result[:url] = '/restaurant_manage/restaurant_image'
    end

    render json: result
  end

  # GET ==== Function: show upload restaurant images view
  def restaurant_image
    if !check_step_info(@restaurant)
      return
    end

    render json: {:success => true, :attachmentPartial => render_to_string('restaurant_manage/restaurant_image', :layout => false ) }
  end

  # POST === Function: upload restaurant images
  def upload_img
    result = RestaurantManage.upload_img(@restaurant, params[:qqfile], request.body.read)
    get_restaurant()
    render json: result
  end

  # GET ==== Function: save the image which is front cover
  def image_cover_save
    result = RestaurantManage.image_cover_save(@restaurant, params[:cover_id])
    get_restaurant()
    render json: result
  end

  # GET ==== Function: destroy select image
  def image_destroy
    result = RestaurantManage.image_destroy(@restaurant, params[:pic_id])
    get_restaurant()
    render json: result
  end

  # GET ==== Function: show supply condition view
  def supply_condition
    if !check_step_image(@restaurant)
      return
    end

    @conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    if @conditions.blank?
      redirect_to '/restaurant_manage/supply_time'
    else
      @special_conditions = @conditions.select { |x| x.is_special == 't' }
      @normal_conditions = @conditions.select { |x| x.is_special != 't' }

      render json: {:success => true, :attachmentPartial => render_to_string('restaurant_manage/supply_condition', :layout => false) }
    end
  end

  # GET ==== Function: show supply time view
  def supply_time
    condition_id = params[:condition_id]
    begin
      @time_zones = RestaurantManage.get_time_zones(condition_id)
      if !condition_id.blank?
        @is_edit = '確定修改'
        @supply_time = SupplyCondition.find(condition_id.to_i)

        @supply_time.range_begin = @supply_time.range_begin.strftime("%Y-%m-%d")
        @supply_time.range_end = @supply_time.range_end.strftime("%Y-%m-%d")
      else
        @is_edit = '確定新增'
        @supply_time = SupplyCondition.new
        @supply_time.available_week = '0,1,2,3,4,5,6'
      end
    rescue => e
      # in this condition is that user change the condition_id
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Action:supply_time"
      @is_edit = '確定新增'
      @supply_time = SupplyCondition.new
      @supply_time.available_week = '0,1,2,3,4,5,6'
      @time_zones = RestaurantManage.get_time_zones(nil)
    end

    render json: {:success => true, :attachmentPartial => render_to_string('restaurant_manage/supply_time', :layout => false) }
  end

  # POST === Function: save supply condition
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
    @special_conditions = @conditions.select { |x| x.is_special == 't' }
    @normal_conditions = @conditions.select { |x| x.is_special != 't' }
    result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :normal_conditions => @normal_conditions, :special_conditions => @special_conditions })
    render json: result
  end

  # POST === Function: save condition state
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
    result = RestaurantManage.destroy_condition(params[:condition_id], @restaurant.id)
    @conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    @special_conditions = @conditions.select { |x| x.is_special == 't' }
    @normal_conditions = @conditions.select { |x| x.is_special != 't' }
    result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :normal_conditions => @normal_conditions, :special_conditions => @special_conditions })
    render json: result
  end

  # GET ==== Function: show special time view
  def special_time
    begin
      @select_date = params[:special_day]
      condition_id = params[:condition_id]
      @time_zones = RestaurantManage.get_time_zones(condition_id)
      if !condition_id.blank? && condition_id.to_i != 0
        condition = SupplyCondition.find(condition_id.to_i)
        @is_vacation = condition.is_vacation
      end
      render 'restaurant_manage/_time_zones', :layout => false
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Action:special_time"
      @time_zones = RestaurantManage.get_time_zones(nil)
    end
  end

  # POST === Function: save special condition
  def special_create
    zones = []
    zones.push(params[:zone0])
    zones.push(params[:zone1])
    zones.push(params[:zone2])
    zones.push(params[:zone3])
    zones.push(params[:zone4])
    zones.push(params[:zone5])


    result =  RestaurantManage.special_create(zones, params[:special_day], @restaurant.id, params[:is_vacation])

    restaurant_month_result = Calendar.get_restaurant_month(nil,nil,@restaurant.id)
    @year = restaurant_month_result[:year]
    @month = restaurant_month_result[:month]
    @books = restaurant_month_result[:books]
    @calendar_data = restaurant_month_result[:calendar_data]
    @id_with_name = restaurant_month_result[:id_with_name]
    #@conditions = SupplyCondition.where(:restaurant_id => @restaurant.id).order('sequence ASC')
    #@special_conditions = @conditions.select { |x| x.is_special == 't' }
    #@normal_conditions = @conditions.select { |x| x.is_special != 't' }
    #result[:attachmentPartial] = render_to_string('restaurant_manage/supply_condition', :layout => false, :locals => { :normal_conditions => @normal_conditions, :special_conditions => @special_conditions })

    result[:attachmentPartial] = render_to_string('calendar/restaurant_month', :layout => false, :locals => { :year => @year, :month => @month, :books => @books, :calendar_data => @calendar_data, :id_with_name => @id_with_name })

    render json: result
  end

  # GET ==== Function: show day booking view
  def day_booking
    @zones_books = RestaurantManage.get_day_books(@restaurant.id, params[:special_day])
    @select_date = params[:special_day]

    render 'restaurant_manage/_day_booking', :layout => false
    #render json: {:success => true, :attachmentPartial => render_to_string('restaurant_manage/_day_booking', :layout => false) }
  end

  # GET ==== Function: show booking report view
  def query_books_by_date
    @from, @to = params[:from], params[:to]
    if @from.blank? || @to.blank?
      now = Time.now
      @from = now.beginning_of_month.to_date.to_s
      @to = now.end_of_month.to_date.to_s
    end
    #@books = RestaurantManage.query_books_by_date(@restaurant.id, params[:range_begin], params[:range_end])
    @books = RestaurantManage.query_books_by_date(@restaurant.id, @from, @to)

    @total_upcoming_people = 0
    @books.each do |b|
      if b.status == '0'
        @total_upcoming_people = @total_upcoming_people + b.num_of_people
      end
    end

    render json: {:success => true, :attachmentPartial => render_to_string('restaurant_manage/_booking_report', :layout => false) }
  end

  # GET ==== Function: show modify booking view
  def modify_booking
    begin
      @booking = Booking.find(params[:booking_id].to_i)
      @time = @booking.booking_time.strftime("%H:%M")
      @booking.booking_time = @booking.booking_time.strftime("%Y-%m-%d")

    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Action:modify_booking"
    end

    render json: {:btime => @time ,:attachmentPartial => render_to_string('restaurant_manage/_modify_booking', :layout => false) }
    #render 'restaurant_manage/_modify_booking', :layout => false
  end

  # POST === Function: save modify booking
  def modify_booking_save
    result = RestaurantManage.modify_booking_save(params[:booking], params[:ti])

    restaurant_month_result = Calendar.get_restaurant_month(nil,nil,@restaurant.id)
    @year = restaurant_month_result[:year]
    @month = restaurant_month_result[:month]
    @books = restaurant_month_result[:books]
    @calendar_data = restaurant_month_result[:calendar_data]
    @id_with_name = restaurant_month_result[:id_with_name]
    result[:attachmentPartial] = render_to_string('calendar/restaurant_month', :layout => false, :locals => { :year => @year, :month => @month, :books => @books, :calendar_data => @calendar_data, :id_with_name => @id_with_name })

     render json: result
  end

  # GET === Function: show cancel booking view
  def cancel_booking
    begin
      @booking = Booking.find(params[:booking_id].to_i)
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/restaurant_manage_controller.rb  ,Action:cancel_booking"
    end

    render 'restaurant_manage/_cancel_booking', :layout => false
  end

  # POST === Function: cancel booking
  def cancel_booking_save
    booking = params[:booking]
    result = RestaurantManage.cancel_booking(booking[:id], booking[:status], booking[:cancel_note])

    restaurant_month_result = Calendar.get_restaurant_month(nil,nil,@restaurant.id)
    @year = restaurant_month_result[:year]
    @month = restaurant_month_result[:month]
    @books = restaurant_month_result[:books]
    @calendar_data = restaurant_month_result[:calendar_data]
    @id_with_name = restaurant_month_result[:id_with_name]
    result[:attachmentPartial] = render_to_string('calendar/restaurant_month', :layout => false, :locals => { :year => @year, :month => @month, :books => @books, :calendar_data => @calendar_data, :id_with_name => @id_with_name })

    render json: result
  end


  def check_step_info(restaurant)
    if !RestaurantManage.check_restaurant_info(restaurant)
      render json: {:error => true, :message => '餐廳資料,必填欄位完善才能進行下一步喔!', :step => '1', :url => '/restaurant_manage/restaurant_info', :attachmentPartial => render_to_string('restaurant_manage/restaurant_info', :layout => false ) }
      return false

    end

    return true
  end

  def check_step_image(restaurant)
    if !RestaurantManage.check_restaurant_info(restaurant)
      render json: {:error => true, :message => '餐廳資料,必填欄位完善才能進行下一步喔!', :step => '1', :url => '/restaurant_manage/restaurant_info', :attachmentPartial => render_to_string('restaurant_manage/restaurant_info', :layout => false ) }
      return false
    end

    if !RestaurantManage.check_restaurant_image(restaurant)
      render json: {:error => true, :message => '餐廳圖片,必填至少上傳一張才能進行下一步喔!', :step => '2', :url => '/restaurant_manage/restaurant_image', :attachmentPartial => render_to_string('restaurant_manage/restaurant_image', :layout => false ) }
      return false
    end

    return true
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

  def  adm_index
    render :layout => false

  end


  def  adm_list_all
    #@restaurant_list = Restaurant.joins('LEFT JOIN(restaurant_users, invite_codes) ON (restaurants.id = restaurant_users.restaurant_id AND restaurant_users.user_id = invite_codes.user_id)').order("id DESC")
    #@restaurant_list = Restaurant.joins('LEFT JOIN(restaurant_users, invite_codes) ON (restaurants.id = restaurant_users.restaurant_id AND restaurant_users.user_id = invite_codes.user_id)')
    #                   .order("id DESC")

    #@restaurant_list = Restaurant.find_by_sql('SELECT * FROM restaurants LEFT JOIN(restaurant_users, invite_codes) ON (restaurants.id = restaurant_users.restaurant_id AND restaurant_users.user_id = invite_codes.user_id)')
    @restaurant_list = Restaurant.find_by_sql('SELECT restaurants.*, invite_codes.code FROM restaurants LEFT JOIN(restaurant_users, invite_codes) ON (restaurants.id = restaurant_users.restaurant_id AND restaurant_users.user_id = invite_codes.user_id) order by restaurants.id desc')

    render :layout => false
  end

  def hack
    session[:hack_restaurant_id] =  params[:id]
    redirect_to '/restaurant#/calendar/restaurant_month'
  end

  def  adm_booking_list
    @booking_list = Booking.order("id DESC").where("name is NOT NULL").limit(100)
    render :layout => false
  end

  def  adm_registration
    @registration_list = User.all.order("id DESC").limit(100)
    render :layout => false
  end


end
