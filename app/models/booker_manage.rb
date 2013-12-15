class BookerManage

  def self.save_feedback(booking_id, feedback)
    begin
      booking = Booking.find(booking_id.to_i)
      booking.feedback = feedback
      booking.save!

      return {:success => true, :data => '儲存成功!'}
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/models/booker_manage.rb  ,Method:save_feedback(booking_id, feedback)"
      return {:error => true, :message => '阿! 發生錯誤了! 儲存失敗!'}
    end
  end




end