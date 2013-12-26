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
      #handle_asynchronously :booking_success #, :run_at => Proc.new { 1.minutes.from_now }
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

      effect_email = []
      email.each do |e|
        if !e.blank? && !(e =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
          effect_email.push(e)
        end
      end

      mail(to: effect_email,
           subject: '訂吧通知：您的朋友邀請您一起用餐！') do |format|
        format.html { render 'my_mailer/booking_friend' }
      end

      return true
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/Mailers/my_mailer.rb ,Method:notify_friend(email, booking_id)"
      return false
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

  def modify_booking(email, booking)
    @booking = booking
    mail(to: email,
         subject: '訂吧通知：您的訂位已由餐廳方修改，請再次確認！') do |format|
      format.html { render 'my_mailer/modify_booking' }
    end
  end

end
