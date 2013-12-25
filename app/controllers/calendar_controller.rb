class CalendarController < ApplicationController
  before_action :get_restaurant, :only => [:restaurant_month, :restaurant_day]

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: wait Front-end engineering ]
  # GET ==== Function: show month calendar
  # =========================================================================
  def restaurant_month
    year = params[:year]
    month = params[:month]

    if year.blank? || month.blank?
      select_year = Time.now.year
      select_month = Time.now.month
    else
      select_year = year.to_i
      select_month = month.to_i
    end

    day_of_mon = Time.days_in_month(select_month, select_year)
    month_start = "#{select_year}-#{select_month}-1"
    conditions = SupplyCondition.where(:restaurant_id => @restaurant.id, :status => 't').where('range_end >= ?', month_start).order('sequence ASC')

    begin
      month_start = "#{select_year}-#{select_month}-1"
      month_end = "#{select_year}-#{select_month}-#{day_of_mon}"
      rid = @restaurant.id
      month_books = DayBooking.where(:restaurant_id => rid, :day => month_start..month_end)
      #=================================

      first_day = Date.parse(month_start)
      last_day = Date.parse(month_end)

      @books = []
      @calendar_data = []
      #=================================
      # init select month all day
      (first_day.day..last_day.day).each do |d|
        c = Calendar.new
        c.day = d

        b = DayBooking.new
        b.zone1 = 0
        b.zone2 = 0
        b.zone3 = 0
        b.zone4 = 0
        b.zone5 = 0
        b.zone6 = 0

        @books.push(b)
        @calendar_data.push(c)
      end
      #==================================

      # change init books to month_books
      month_books.each do |b|
        index = b.day.day.to_i - 1
        @books[index] = b
      end
      #==================================

      @id_with_name = {}
      # set condition to calendar
      conditions.each do |con|
        @id_with_name[con.id]= con.name

        week = con.available_week.split(',')
        week = week.collect{|e| e.to_i}

        (con.range_begin > first_day) ? begin_day = Date.parse(con.range_begin.to_s) : begin_day = first_day
        (con.range_end > last_day) ? end_day = last_day : end_day = Date.parse(con.range_end.to_s)
        zones = TimeZone.where(:supply_condition_id => con.id,:status => 't').order('sequence ASC')

        (begin_day..end_day).each do |t|
          index = t.day.to_i - 1
          c =  @calendar_data[index]

          if week.include?(t.wday) && (c.con_id.blank? || c.con_id == 0 )   # 0 mean range have but no setting
            c.con_id = con.id
            c.name = con.name

            if con.is_special == 't'
              c.is_special = true
            end

            zones.each { |z|
              if z.sequence == 0
                c.n1 = z.name
                c.z1 = z.total_allow
              elsif z.sequence == 1
                c.n2 = z.name
                c.z2 = z.total_allow
              elsif z.sequence == 2
                c.n3 = z.name
                c.z3 = z.total_allow
              elsif z.sequence == 3
                c.n4 = z.name
                c.z4 = z.total_allow
              elsif z.sequence == 4
                c.n5 = z.name
                c.z5 = z.total_allow
              elsif z.sequence == 5
                c.n6 = z.name
                c.z6 = z.total_allow
              end }

            @calendar_data[index] = c

          elsif c.con_id.blank?
            c.con_id = 0
          end
        end
      end
      #==================================

      # put nil day to calendar array top
      first_day.wday.to_i.times do
        pre = Calendar.new
        pre.day = 0
        @calendar_data.unshift(pre)
      end

      difference = 35 - @calendar_data.length
      if difference > 0
        difference.times do
          after = Calendar.new
          after.day = 0
          @calendar_data.push(after)
        end
      elsif @calendar_data.length > 35
        difference = 42 -@calendar_data.length
        difference.times do
          after = Calendar.new
          after.day = 0
          @calendar_data.push(after)
        end
      end
      #==================================
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/calendar_controller.rb  ,Action:res_month"
    end

    @year = select_year
    @month = select_month

    render 'calendar/restaurant_month', :layout => false
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: ok ]
  # GET ==== Function: show day booking
  # =========================================================================
  def restaurant_day
    @select_date = params[:select_date]
    @select_date = Time.now.to_s if @select_date.blank?
    @zones_books = RestaurantManage.get_day_books(@restaurant.id, @select_date)
    @select_date = @select_date.to_date
    render 'restaurant_manage/_day_booking', :layout => false
  end

  # ====== Code Check: 2013/12/07 ====== [ panda: TODO: 1.rename @res to @restaurant 2.think the auth solution ]
  # func ==== Function: auth user and get restaurant
  # =========================================================================
  def get_restaurant
    begin
      if current_user.blank?
        flash.now[:alert] = '您還沒登入喔!~~ '
        redirect_to res_session_new_path
      else
        if current_user.role == '0'
          manage_restaurants = RestaurantUser.where(:user_id => current_user.id)
          if !manage_restaurants.blank?         # system error
            target = manage_restaurants.first   # let user choose restaurant to mange, in phase 2

            @restaurant = Restaurant.find(target.restaurant_id)
            @res_url = APP_CONFIG['domain'] + @restaurant.res_url.to_s
          end
        elsif current_user.role == '1'
          redirect_to booker_manage_index_path
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/calendar_controller.rb  ,Filter:get_restaurant"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      redirect_to res_session_new_path
    end
  end

end