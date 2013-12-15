class MyMailer < ActionMailer::Base
  default from: "a17877yun@gmail.com"

  def booking_success(email, booking)
    begin
      @booking = booking
      #email = 'a17877yun@gmail.com'
      mail(to: email,
           subject: '訂吧通知：您的訂位成功！') do |format|
        format.html { render 'my_mailer/booking_success' }
      end

      return true
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/booking_success.rb ,Method:booking_success(email, booking_id)"
      return false
    end
  end

  def notify_friend(email, booking_id)
    begin
      @booking = Booking.find(booking_id)
      #email = 'a17877yun@gmail.com,u9523039@yuntech.edu.tw'
      email = email.split(',')

      mail(to: email,
           subject: '訂吧通知：您的朋友邀請您一起用餐！') do |format|
        format.html { render 'my_mailer/booking_friend' }
      end

      return {:success => true, :data => '通知成功!' }
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:notify_friend(email, booking_id)"
      return {:error => true, :message => '阿! 發生錯誤了! 通知失敗!'}
    end
  end

  def cancel_booking(email, booking)
    #email = 'a17877yun@gmail.com'

    @booking = booking
    mail(to: email,
         subject: '訂吧通知：您的訂位已取消！') do |format|
      format.html { render 'my_mailer/cancel_booking' }
    end
  end

end
