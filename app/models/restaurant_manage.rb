class RestaurantManage

  def self.check_restaurant_info(restaurant)
    if restaurant.name.blank? || restaurant.address.blank? || restaurant.phone.blank? ||
        restaurant.business_hours.blank? || restaurant.supply_person.blank?
      return false
    else
      return true
    end
  end

  def self.check_supply_condition(restaurant_id)
    effect_conditions = SupplyCondition.where(:restaurant_id => restaurant_id, :status => 't').where('range_end >= ?', Time.now)

    if effect_conditions.blank?
      return false
    else
      return true
    end
  end

  def self.restaurant_info_save(origin_restaurant)
    begin
      restaurant = Restaurant.find(origin_restaurant[:id].to_i)
      restaurant.name = origin_restaurant[:name]
      restaurant.phone = origin_restaurant[:phone]
      restaurant.city = origin_restaurant[:city]
      restaurant.area = origin_restaurant[:area]
      restaurant.address = origin_restaurant[:address]
      restaurant.res_type = origin_restaurant[:res_type]
      restaurant.feature = origin_restaurant[:feature]

      pay_type_cash = origin_restaurant[:pay_type_cash]
      pay_type_CreditCard = origin_restaurant[:pay_type_CreditCard]
      pay_type_EasyCard = origin_restaurant[:pay_type_EasyCard]

      pay_type = [origin_restaurant[:pay_type_cash], origin_restaurant[:pay_type_CreditCard], origin_restaurant[:pay_type_EasyCard]].join(',')
      # pay_type = pay_type_cash if !pay_type_cash.blank?
      # pay_type = pay_type + ',' + pay_type_CreditCard if !pay_type_CreditCard.blank?
      # pay_type = pay_type + ',' + pay_type_EasyCard if !pay_type_EasyCard.blank?
      restaurant.pay_type = pay_type

      restaurant.business_hours = origin_restaurant[:business_hours]
      restaurant.supply_person = origin_restaurant[:supply_person]
      restaurant.supply_email = origin_restaurant[:supply_email]
      restaurant.url1 = origin_restaurant[:url1]
      restaurant.url2 = origin_restaurant[:url2]
      restaurant.url3 = origin_restaurant[:url3]
      restaurant.info_url1 = origin_restaurant[:info_url1]
      restaurant.info_url2 = origin_restaurant[:info_url2]
      restaurant.info_url3 = origin_restaurant[:info_url3]
      restaurant.save

      return {:success => true, :data => '儲存成功!'}
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:res_info_save(restaurant_info)"
      return {:error => true, :message => '阿! 發生錯誤了! 儲存失敗!'}
    end
  end

  def self.upload_img(restaurant, qqfile, data)
    begin
      path = File.expand_path("./public/res/#{restaurant.id}/images/", Rails.root)
      now = Time.now.to_i.to_s + Random.rand(9999).to_s
      FileUtils.mkdir_p(path) unless File.directory?(path)
      ex_name = qqfile.split('.').pop
      filename = "#{now}.#{ex_name}"

      if restaurant.pic_name1.blank?
        restaurant.pic_name1 = filename
      elsif restaurant.pic_name2.blank?
        restaurant.pic_name2 = filename
      elsif restaurant.pic_name3.blank?
        restaurant.pic_name3 = filename
      elsif restaurant.pic_name4.blank?
        restaurant.pic_name4 = filename
      elsif restaurant.pic_name5.blank?
        restaurant.pic_name5 = filename
      else
        return {:error => true, :message => '只能上傳五張圖片!'}
      end

      fullpath = File.expand_path(filename, path)
      File.open(fullpath, 'wb'){ |file| file.write(data) }
      restaurant.save

      image_path = {}
      image_path[1] = "res/#{restaurant.id}/images/" + restaurant.pic_name1 if !restaurant.pic_name1.blank?
      image_path[2] = "res/#{restaurant.id}/images/" + restaurant.pic_name2 if !restaurant.pic_name2.blank?
      image_path[3] = "res/#{restaurant.id}/images/" + restaurant.pic_name3 if !restaurant.pic_name3.blank?
      image_path[4] = "res/#{restaurant.id}/images/" + restaurant.pic_name4 if !restaurant.pic_name4.blank?
      image_path[5] = "res/#{restaurant.id}/images/" + restaurant.pic_name5 if !restaurant.pic_name5.blank?

      return {:success => true, :image_path => image_path }
    rescue Exception => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:upload_img(restaurant, qqfile, data)"
      return {:error => true, :message => '阿! 發生錯誤了! 上傳失敗!'}
    end
  end

  def self.image_cover_save(restaurant, cover_id)
    begin
      if (cover_id == '1' && restaurant.pic_name1.blank?) || (cover_id == '2' && restaurant.pic_name2.blank?) || (cover_id == '3' && restaurant.pic_name3.blank?) ||
          (cover_id == '4' && restaurant.pic_name4.blank?) || (cover_id == '5' && restaurant.pic_name5.blank?)

        return {:error => true, :message => '有圖片才能設為封面喔!'}
      else
        restaurant.front_cover = cover_id
        restaurant.save

        return {:success => true, :data => '封面設定完畢!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:img_cover_save(restaurant, cover_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 設定失敗!'}
    end
  end

  def self.image_destroy(restaurant, pic_id)
    begin
      pic_name = nil
      if pic_id == '1'
        pic_name = restaurant.pic_name1
        restaurant.pic_name1 = nil
      elsif pic_id == '2'
        pic_name = restaurant.pic_name2
        restaurant.pic_name2 = nil
      elsif pic_id == '3'
        pic_name = restaurant.pic_name3
        restaurant.pic_name3 = nil
      elsif pic_id == '4'
        pic_name = restaurant.pic_name4
        restaurant.pic_name4 = nil
      elsif pic_id == '5'
        pic_name = restaurant.pic_name5
        restaurant.pic_name5 = nil
      end

      if !pic_name.blank?
        if restaurant.front_cover == pic_id
          if !restaurant.pic_name1.blank?
            restaurant.front_cover = '1'
          elsif !restaurant.pic_name2.blank?
            restaurant.front_cover = '2'
          elsif !restaurant.pic_name3.blank?
            restaurant.front_cover = '3'
          elsif !restaurant.pic_name4.blank?
            restaurant.front_cover = '4'
          elsif !restaurant.pic_name5.blank?
            restaurant.front_cover = '5'
          else
            restaurant.front_cover = nil
          end
        end

        path = File.expand_path("./public/res/#{restaurant.id}/images/", Rails.root)
        File.delete(path + '/' + pic_name)
        restaurant.save

        image_path = {}
        image_path[1] = "res/#{restaurant.id}/images/" + restaurant.pic_name1 if !restaurant.pic_name1.blank?
        image_path[2] = "res/#{restaurant.id}/images/" + restaurant.pic_name2 if !restaurant.pic_name2.blank?
        image_path[3] = "res/#{restaurant.id}/images/" + restaurant.pic_name3 if !restaurant.pic_name3.blank?
        image_path[4] = "res/#{restaurant.id}/images/" + restaurant.pic_name4 if !restaurant.pic_name4.blank?
        image_path[5] = "res/#{restaurant.id}/images/" + restaurant.pic_name5 if !restaurant.pic_name5.blank?

        return {:success => true, :data => '刪除成功!', :image_path => image_path }
      else
        return {:error => true, :message => '沒有圖片~ 無法刪除!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:img_destroy(restaurant, pic_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 刪除失敗!'}
    end
  end

  def self.supply_condition_create(restaurant_id, origin_condition, origin_zones)
    begin
      SupplyCondition.transaction do
        target_condition = SupplyCondition.new

        # why set sequence in this area => because the supply_condition_save method have multi usage, and they don't set sequence
        target_condition.sequence = SupplyCondition.maximum(:sequence) + 1
        target_condition.sequence.blank?  ? target_condition.sequence = 1 : target_condition.sequence
        condition_id = supply_condition_save(origin_condition, restaurant_id, target_condition)

        if condition_id.blank?
          return {:error => true, :message => '阿! 發生錯誤了! 新增失敗!'}
        end

        # why init target_zones in this area => because the time_zone_save method have multi usage, and they don't init target_zones
        target_zones = []
        6.times do
          target_zones.push(TimeZone.new)
        end
        time_zone_save(origin_zones, condition_id, target_zones)

        return {:success => true, :data => '新增供位條件成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:supply_condition_create(restaurant_id, origin_condition, origin_zones)"
      return {:error => true, :message => '阿! 發生錯誤了! 新增失敗!'}
    end
  end

  def self.supply_condition_update(restaurant_id, origin_condition, origin_zones)
    begin
      SupplyCondition.transaction do
        condition_id = supply_condition_save(origin_condition, restaurant_id, SupplyCondition.find(origin_condition[:id].to_i))

        if condition_id.blank?
          return {:error => true, :message => '阿! 發生錯誤了! 修改失敗!'}
        end

        zones = TimeZone.where(:supply_condition_id => origin_condition[:id].to_i).order('sequence ASC')
        time_zone_save(origin_zones, condition_id, zones)
        return {:success => true, :data => '修改成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:supply_condition_update(restaurant_id, origin_condition, origin_zones)"
      return {:error => true, :message => '阿! 發生錯誤了! 修改失敗!'}
    end
  end

  def self.supply_condition_save(origin_condition, restaurant_id, target_condition)
    #begin
      target_condition.restaurant_id = restaurant_id
      target_condition.name = origin_condition[:name]
      target_condition.range_begin = origin_condition[:range_begin]
      target_condition.range_end = origin_condition[:range_end]
      target_condition.available_week = "#{origin_condition[:week1]},#{origin_condition[:week2]},#{origin_condition[:week3]},#{origin_condition[:week4]},#{origin_condition[:week5]},#{origin_condition[:week6]},#{origin_condition[:week7]}"
      target_condition.status = 't'   # t = enable ,f = disable
      target_condition.save
      return target_condition.id
    #rescue => e
    #  Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:supply_condition_save(origin_condition, restaurant_id, target_condition)"
    #  return nil
    #end
  end

  def self.time_zone_save(origin_zones, condition_id, target_zones)
    #TODO: batch save
    #begin
      zones = []
      origin_zones.each_with_index do |origin_zone, index|
        zone = target_zones[index]
        zone.supply_condition_id = condition_id
        zone.sequence = index
        origin_zone[:enable].blank? ? zone.status = 'f' : zone.status = 't'
        zone.name = origin_zone[:name]
        zone.range_begin = origin_zone[:time_begin]
        zone.range_end = origin_zone[:time_end]
        zone.total_allow = origin_zone[:total_allow]
        zone.each_allow = origin_zone[:each_allow]
        zone.fifteen_allow = origin_zone[:fifteen_allow]
        zones.push(zone)
      end

      zones.length.times do |i|
        zones.length.times do |j|
          temp_max_zone = zones[j]
          if !zones[j + 1].blank?
            temp_begin = zones[j + 1].range_begin.split(':')
            if zones[j + 1].range_begin < zones[j].range_begin
              if temp_begin[0] != '00'
                temp_max_zone = zones[j]
                zones[j]= zones[j + 1]
                zones[j + 1] = temp_max_zone
              end
            end
          end
        end
      end

      zones.each_with_index do |zone, index|
        zone.sequence = index
        zone.save
      end

      return true
    #rescue => e
    #  Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:time_zone_save(origin_zones, condition_id, target_zones)"
    #  return false
    #end
  end

  def self.destroy_condition(condition_id)
    if !condition_id.blank?
      begin
        condition_id = condition_id.to_i
        SupplyCondition.transaction do
          SupplyCondition.find(condition_id).destroy
          TimeZone.where(:supply_condition_id => condition_id).destroy_all
          return {:success => true, :data => '刪除成功!' }
        end
      rescue => e
        Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:destroy_condition(condition_id)"
        return {:error => true, :message => '阿! 發生錯誤了! 刪除失敗!'}
      end
    else
      return {:error => true, :message => '阿! 發生錯誤了! 找不到此條件!'}
    end
  end

  def self.special_create(origin_zones, special_day, restaurant_id)
    begin
      special_day = Time.parse(special_day)
      origin = SupplyCondition.where(:restaurant_id => restaurant_id, :is_special => 't').where('range_begin >= ?', special_day).where('range_end <= ?', special_day)

      origin_id = 0
      is_origin = false
      if !origin.blank?
        origin_id = origin.first.id
        is_origin = true
      end

      target_zones = []
      6.times do
        target_zones.push(TimeZone.new)
      end

      if origin_id != 0
        condition_id = origin_id
      else
        condition_id = SupplyCondition.maximum(:id) + 1
      end

      SupplyCondition.transaction do
        # destroy orign
        if is_origin == true
          origin.first.destroy
          TimeZone.where(:supply_condition_id => origin.first.id).destroy_all
        end

        # special day condition
        condition = SupplyCondition.new
        condition.id = condition_id
        condition.restaurant_id = restaurant_id
        condition.name = Date.parse(special_day.to_s).to_s
        condition.status = 't'
        condition.range_begin = special_day
        condition.range_end = special_day
        condition.available_week = '0,1,2,3,4,5,6'
        condition.sequence = 0
        condition.is_special = 't'
        condition.save

        # special time zone save
        time_zone_save(origin_zones, condition_id, target_zones)
        return {:success => true, :data => '新增特定日供位條件成功!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:special_create(origin_zones, special_day, restaurant_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 設定失敗!'}
    end
  end

  def self.condition_state_save(data, restaurant)
    begin
      SupplyCondition.transaction do
        # parse json
        data_parsed = JSON.parse(data)

        # split id and status
        condition_id_list = data_parsed['id_list']
        condition_status_list = data_parsed['status_list']

        # split each element
        condition_id_list = condition_id_list.split(',')
        condition_status_list = condition_status_list.split(',')

        # get condition length
        condition_length = condition_id_list.length

        # validation data
        if condition_length != condition_status_list.length
          # TODO ajax data error, hacker condition
        end

        # get this restaurant all condition
        conditions = SupplyCondition.where(:restaurant_id => restaurant.id.to_i)

        # validation data
        if condition_length != conditions.length
          # TODO ajax data error, hacker condition
        end

        # string to integer
        condition_id_list = condition_id_list.collect{|i| i.to_i}

        # save change
        conditions.each do |c|
          condition_id_list.each_with_index do |cid, index|
            if c.id == cid
              c.sequence = index
              c.status = condition_status_list[index]
              c.save
              break
            end
          end
        end

        # save reserve data
        restaurant.available_hour = data_parsed['reserve_hour'].to_i
        restaurant.available_date = data_parsed['reserve_previous_hour']
        restaurant.available_type = data_parsed['reserve_type']
        restaurant.save

        return conditions
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:condition_state_save(data, restaurant)"
      return nil
    end
  end

  def self.get_time_zones(condition_id)
    time_zones = []
    if condition_id.blank? || condition_id == '0'   # active record default id start is 1, so i can use 0 to mark no condition
      zone1 = TimeZone.new
      zone1.name = '早餐'
      zone1.range_begin = '06:00'
      zone1.range_end = '10:00'
      time_zones.push(zone1)

      zone2 = TimeZone.new
      zone2.name = '早午餐'
      zone2.range_begin = '10:00'
      zone2.range_end = '12:00'
      time_zones.push(zone2)

      zone3 = TimeZone.new
      zone3.name = '午餐'
      zone3.range_begin = '12:00'
      zone3.range_end = '14:00'
      time_zones.push(zone3)

      zone4 = TimeZone.new
      zone4.name = '下午茶'
      zone4.range_begin = '14:00'
      zone4.range_end = '17:00'
      time_zones.push(zone4)

      zone5 = TimeZone.new
      zone5.name = '晚餐'
      zone5.range_begin = '17:00'
      zone5.range_end = '21:00'
      time_zones.push(zone5)

      zone6 = TimeZone.new
      zone6.name = '宵夜'
      zone6.range_begin = '21:00'
      zone6.range_end = '24:00'
      time_zones.push(zone6)
    else
      zones = TimeZone.where(:supply_condition_id => condition_id)  # if add .to_i must add begin recure
      zones.each do |z|
        time_zones.push(z)
      end
    end
    return time_zones
  end

  def self.get_day_books(restaurant_id, special_day)
    begin
      special_day = Date.parse(special_day)

      # FIX  where below
      day_books = Booking.where(:restaurant_id => restaurant_id).where('booking_time >= ?', special_day).where('booking_time <= ?', special_day + 1.days).order('booking_time ASC')

      # why use this solution => because use day to know the condition is too slow , so i use books to get the condition id ,if no book, just show no one booking
      if !day_books.blank?
        temp_zone = TimeZone.find(day_books.first.time_zone_id)
        zones = TimeZone.where(:supply_condition_id => temp_zone.supply_condition_id)

        zones_books = []
        if !zones.blank?
          zones.each do |z|
            has_books = false

            books = []
            day_books.each do |b|
              if z.id == b.time_zone_id
                books.push(b)
                has_books = true
                #day_books.delete(b)  # TODO already push in books pop up the day_books
              end
            end

            if has_books == true
              zone_booking = ZoneBooking.new
              zone_booking.name = z.name
              zone_booking.books = books
              zones_books.push(zone_booking)
            end
          end
        end

        return zones_books
      else
        return nil
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:get_day_books(restaurant_id, special_day)"
      return nil
    end
  end

  def self.query_books_by_date(restaurant_id, date_start, date_end)
    begin
      if date_start.blank? && date_end.blank?
        now_month = Time.now.month
        now_year = Time.now.year
        daysOfMon = Time.days_in_month(now_month, now_year)
        date_start = "#{now_year}-#{now_month}-1"
        date_end = "#{now_year}-#{now_month}-#{daysOfMon}"
      end

      date_start = Time.parse(date_start)
      date_end = Time.parse(date_end)

      return Booking.where(:restaurant_id => restaurant_id).where('booking_time >= ?', date_start).where('booking_time <= ?', date_end).order('booking_time ASC')
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:query_books_by_date(restaurant_id, date_start, date_end)"
      return nil
    end
  end

  def self.modify_booking_save(origin_booking)
    begin
      booking = Booking.find(origin_booking[:id].to_i)
      booking.name = origin_booking[:name]
      booking.phone = origin_booking[:phone]
      booking.email = origin_booking[:email]
      booking.booking_time = origin_booking[:booking_time]
      booking.num_of_people = origin_booking[:num_of_people]
      booking.remark = origin_booking[:remark]
      booking.save

      return {:success => true, :data => '修改成功!'}
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:modify_booking_save(origin_booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 修改失敗!'}
    end
  end

  def self.cancel_booking(origin_booking)
    begin
      booking = Booking.find(origin_booking[:id].to_i)
      booking.status = origin_booking[:status]
      booking.cancel_note = origin_booking[:cancel_note] if booking.status == '6'
      booking.save

      MyMailer.cancel_booking(booking.email ,booking).deliver

      return {:success => true, :data => '已取消訂位!'}
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/restaurant_manage.rb  ,Method:cancel_booking(origin_booking)"
      return {:error => true, :message => '阿! 發生錯誤了! 取消訂位失敗!'}
    end
  end



end