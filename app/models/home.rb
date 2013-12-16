class Home

  def self.get_restaurant(restaurant_url)
    begin
      return Restaurant.where(:res_url => restaurant_url).first
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Models/home.rb  ,Method:get_restaurant(restaurant_url)"
      return nil
    end
  end

  def self.get_condition(restaurant, booking_day)
    begin
      #restaurant = Restaurant.where(:res_url => restaurant_url).first
      restaurant = restaurant
      booking_condition = BookingCondition.new

      if booking_day.blank?
        booking_day = Date.parse(Time.now.to_s) # + 1.days
      else
        booking_day = Date.parse(booking_day)

        if booking_day <= Date.parse(Time.now.to_s)
          return {:error => true, :message => '不能選過去的時間喔!'}
        end
      end

      booking_day_begin = Time.parse(booking_day.strftime("%Y-%m-%d") + " 00:00")
      booking_day_end = Time.parse(booking_day.strftime("%Y-%m-%d") + " 23:59")

      conditions = SupplyCondition.where(:restaurant_id => restaurant.id, :status => 't').where('range_end >= ?', booking_day_begin).where('range_begin <= ?', booking_day_begin).order('sequence ASC')

      if conditions.blank?
        return {:error => true, :message => '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'}
      end
      #=========================================================================

      effect_condition = nil

      conditions.each do |condition|
        week = condition.available_week.split(',')
        week = week.collect{|e| e.to_i}

        if week.include?(booking_day.wday)
          effect_condition = condition
          break
        end
      end

      if effect_condition.blank?
        return {:error => true, :message => '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'}
      end
      #=========================================================================

      zones = TimeZone.where(:supply_condition_id => effect_condition.id, :status => 't').order('sequence ASC')

      if zones.blank?
        return {:error => true, :message => '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'}
      end
      #=========================================================================

      if !restaurant.available_type.blank? && restaurant.available_type == '0'
        limit_hour = restaurant.available_hour
      elsif !restaurant.available_type.blank? && restaurant.available_type == '1'
        limit_day_time = restaurant.available_date
      end

      is_today = false
      if booking_day == Date.parse(Time.now.to_s)
        is_today = true
      end

      if is_today && !limit_day_time.blank?
        return {:error => true, :message => '目前這個時段，餐廳沒有開放的訂位，請選擇較後面的日期查看喲!'}
      end
      #=========================================================================

      booking_condition = BookingCondition.new
      booking_condition.option_max_people = []    # [1, 2, 3, 4 ....]
      booking_condition.option_of_people = []     # [zone.each_allow, zone.id, zone.name], [....]
      booking_condition.option_of_time = []       # ['12:00', '12:15' ....]

      use_type = 0
      if !is_today && !limit_day_time.blank?      # =========================================
        # booking day not today and use limit_day_time condition
        use_type = 1

        zones.each do |z|
          if limit_day_time >= z.range_begin
            zone_option_of_people = []
            zone_option_of_people.push(z.each_allow)
            zone_option_of_people.push(z.id)
            zone_option_of_people.push(z.name)
            booking_condition.option_of_people.push(zone_option_of_people)

            temp_begin = z.range_begin.split(':')
            temp_begin_hour = temp_begin[0]
            temp_begin_minute = temp_begin[1]     # if this != 00 then after delete 2

            if limit_day_time > z.range_end
              range_end = z.range_end
            else
              range_end = limit_day_time
            end

            # add gray
            origin_range_end = z.range_end.split(':')
            origin_end_hour = origin_range_end[0]
            origin_end_hour = '24' if origin_range_end == '00'
            origin_end_minute = origin_range_end[1]       # if this != 00 then after add 2
            # end add ========

            temp_end = range_end.split(':')
            temp_end_hour = temp_end[0]
            temp_end_hour = '24' if temp_end_hour == '00'
            temp_end_minute = temp_end[1]       # if this != 00 then after add 2
            temp_end_hour = temp_end_hour.to_i  # add

            zone_option_of_time = []

            # add gray
            temp_begin_hour = temp_begin_hour.to_i
            origin_end_hour = origin_end_hour.to_i
            (temp_begin_hour..origin_end_hour).each do |h|
              if h <= temp_end_hour
                zone_option_of_time.push([0,h.to_s + ":00"])     # [[gray],[time]]
                zone_option_of_time.push([0,h.to_s + ":15"])
                zone_option_of_time.push([0,h.to_s + ":30"])
                zone_option_of_time.push([0,h.to_s + ":45"])
              else
                zone_option_of_time.push([1,h.to_s + ":00"])
                zone_option_of_time.push([1,h.to_s + ":15"])
                zone_option_of_time.push([1,h.to_s + ":30"])
                zone_option_of_time.push([1,h.to_s + ":45"])
              end
            end
            # end add ========

            #temp_begin_hour = temp_begin_hour.to_i
            #temp_end_hour = temp_end_hour.to_i
            #(temp_begin_hour..temp_end_hour).each do |h|
            #  zone_option_of_time.push(h.to_s + ":00")
            #  zone_option_of_time.push(h.to_s + ":15")
            #  zone_option_of_time.push(h.to_s + ":30")
            #  zone_option_of_time.push(h.to_s + ":45")
            #end

            if temp_begin_minute == '30'
              2.times do
                zone_option_of_time.delete_at(0)
              end
            end

            if origin_end_minute == '00'
              3.times do
                zone_option_of_time.delete_at(zone_option_of_time.length - 1)
              end
            elsif origin_end_minute == '30'
              zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            end

            #if temp_end_minute == '00'
            #  3.times do
            #    zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            #  end
            #elsif temp_end_minute == '30'
            #  zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            #end

            zone_option_of_time.unshift(z.id)
            booking_condition.option_of_time.push(zone_option_of_time)
          end

        end

        max_people = 0
        target_index = 0
        booking_condition.option_of_time.length.times do |i|

          if booking_condition.option_of_people[i][0] > max_people
            max_people = booking_condition.option_of_people[i][0]
            target_index = i
          end

          if booking_condition.option_of_time.length != (i + 1)
            booking_condition.option_of_time[i] = booking_condition.option_of_time[i] - booking_condition.option_of_time[i + 1]
          end
        end


        booking_condition.option_of_people[target_index][0].times do |i|
          booking_condition.option_max_people.push(i + 1)
        end

        #booking_day_begin = booking_day.strftime("%Y-%m-%d ")
        #booking_day_end = (booking_day + 1.days).strftime("%Y-%m-%d ")
        booking_day_begin = Time.parse(booking_day.strftime("%Y-%m-%d") + " 00:00")
        booking_day_end = Time.parse(booking_day.strftime("%Y-%m-%d") + " 23:59")
        bookings_of_select_day = Booking.where('booking_time >= ?', booking_day_begin).where('booking_time <= ?', booking_day_end).group('booking_time').sum(:num_of_people)


        bookings_of_select_day.each do |b|
          b= b

        end


        return booking_condition

      elsif !limit_hour.blank?                  # =========================================
        # use pre hour condition
        use_type = 2
        temp_booking_day = booking_day.strftime("%Y-%m-%d ")

        zones.each do |z|

          all_block = false    # add gray
          is_effect = false
          range_begin = Time.parse(temp_booking_day + z.range_begin)
          range_end = Time.parse(temp_booking_day + z.range_end)
          effect_time_begin = Time.now + limit_hour.hour
          if effect_time_begin >= range_begin && effect_time_begin < range_end
            temp_begin_hour = effect_time_begin.strftime("%H")
            temp_begin_minute = effect_time_begin.strftime("%M")
            temp_end_hour = range_end.strftime("%H")
            temp_end_hour = '24' if temp_end_hour == '00'
            temp_end_minute = range_end.strftime("%M")

            is_effect = true
          elsif effect_time_begin < range_begin
            temp_begin_hour = range_begin.strftime("%H")
            temp_begin_minute = range_begin.strftime("%M")
            temp_end_hour = range_end.strftime("%H")
            temp_end_hour = '24' if temp_end_hour == '00'
            temp_end_minute = range_end.strftime("%M")
            is_effect = true
          else
            all_block = true
            is_effect = true # add gray
          end

          # add gray
          origin_begin_hour = range_begin.strftime("%H")
          origin_begin_minute = range_begin.strftime("%M")
          origin_end_hour = range_end.strftime("%H")
          origin_end_hour = '24' if origin_end_hour == '00'
          origin_end_minute = range_end.strftime("%M")
          # end add ========

          if is_effect
            zone_option_of_people = []
            zone_option_of_people.push(z.each_allow)
            zone_option_of_people.push(z.id)
            zone_option_of_people.push(z.name)
            booking_condition.option_of_people.push(zone_option_of_people)

            zone_option_of_time = []
            # add gray
            temp_begin_hour = temp_begin_hour.to_i
            temp_end_hour = temp_end_hour.to_i
            origin_begin_hour = origin_begin_hour.to_i
            origin_end_hour = origin_end_hour.to_i
            (origin_begin_hour..origin_end_hour).each do |h|
              if all_block || h < temp_begin_hour
                zone_option_of_time.push([1,h.to_s + ":00"])     # [[gray],[time]]
                zone_option_of_time.push([1,h.to_s + ":15"])
                zone_option_of_time.push([1,h.to_s + ":30"])
                zone_option_of_time.push([1,h.to_s + ":45"])
              else
                zone_option_of_time.push([0,h.to_s + ":00"])
                zone_option_of_time.push([0,h.to_s + ":15"])
                zone_option_of_time.push([0,h.to_s + ":30"])
                zone_option_of_time.push([0,h.to_s + ":45"])
              end
            end
            # end add ========


            #temp_begin_hour = temp_begin_hour.to_i
            #temp_end_hour = temp_end_hour.to_i
            #(temp_begin_hour..temp_end_hour).each do |h|
            #  zone_option_of_time.push(h.to_s + ":00")
            #  zone_option_of_time.push(h.to_s + ":15")
            #  zone_option_of_time.push(h.to_s + ":30")
            #  zone_option_of_time.push(h.to_s + ":45")
            #end

            if temp_begin_minute == '30'
              2.times do
                zone_option_of_time.delete_at(0)
              end
            end

            #if temp_begin_minute > '00' && temp_begin_minute <= '15'        # >= 00 or > 00
            #  zone_option_of_time.delete_at(0)
            #elsif (temp_begin_minute > '15' && temp_begin_minute <= '30')
            #  2.times do
            #    zone_option_of_time.delete_at(0)
            #  end
            #elsif temp_begin_minute > '30' && temp_begin_minute <= '45'
            #  3.times do
            #    zone_option_of_time.delete_at(0)
            #  end
            #elsif temp_begin_minute > '45' && temp_begin_minute <= '59'
            #  4.times do
            #    zone_option_of_time.delete_at(0)
            #  end
            #end

            if origin_end_minute == '00'
              3.times do
                zone_option_of_time.delete_at(zone_option_of_time.length - 1)
              end
            elsif origin_end_minute == '30'
              zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            end

            #if temp_end_minute == '00'
            #  3.times do
            #    zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            #  end
            #elsif temp_end_minute == '30'
            #  zone_option_of_time.delete_at(zone_option_of_time.length - 1)
            #end

            zone_option_of_time.unshift(z.id)
            booking_condition.option_of_time.push(zone_option_of_time)
          end
        end

        max_people = 0
        target_index = 0
        booking_condition.option_of_time.length.times do |i|

          if booking_condition.option_of_people[i][0] > max_people
            max_people = booking_condition.option_of_people[i][0]
            target_index = i
          end

          if booking_condition.option_of_time.length != (i + 1)
            booking_condition.option_of_time[i] = booking_condition.option_of_time[i] - booking_condition.option_of_time[i + 1]
          end
        end


        booking_condition.option_of_people[target_index][0].times do |i|
          booking_condition.option_max_people.push(i + 1)
        end

        return booking_condition
      end

    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Models/home.rb  ,Method:get_condition(restaurant_url, booking_day)"
      return
    end
  end

  def self.save_booking(booker, origin_booking)
    begin
      is_pass = false
      restaurant = Restaurant.find(origin_booking[:restaurant_id])

      if origin_booking[:booker_id].blank? && !booker.blank?
        is_pass = true
      elsif booker.id != origin_booking[:booker_id].to_i       # check null params value can to_i ?
        return {:error => true, :message => '阿! 發生錯誤了! 訂位失敗!'}
      elsif booker.id == origin_booking[:booker_id].to_i
        is_pass = true
      end

      if is_pass == true
        booking = Booking.new
        booking.user_id = booker.id
        booking.restaurant_id = restaurant_id
        booking.res_url = restaurant.res_url
        booking.restaurant_name = restaurant.name
        booking.restaurant_address = restaurant.city + restaurant.area + restaurant.address
        booking.booking_time = origin_booking[:booking_time]
        booking.num_of_people = origin_booking[:num_of_people]
        booking.name = origin_booking[:booker_name]
        booking.phone = origin_booking[:booker_phone]
        booking.email = origin_booking[:booker_email]
        booking.remark = origin_booking[:booker_remark]
        booking.save

        send_mail_result = MyMailer.booking_success(booking.email, booking).deliver   # Send mail fail may be the email problem, check time out

        return {:success => true, :data => '訂位成功!', :booking_id => booking.id }
      else
        return {:error => true, :message => '阿! 發生錯誤了! 訂位失敗!'}
      end

    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Models/home.rb  ,Method:save_booking(user_id, booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 訂位失敗!'}
    end
  end
end