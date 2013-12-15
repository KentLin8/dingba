class MyMailer < ActionMailer::Base
  default from: "a17877yun@gmail.com"


  def booking_success(email, booking)

    email = 'a17877yun@gmail.com'

    @booking = booking
    mail(to: email,
         subject: '訂吧通知：您的訂位成功！') do |format|
      format.html { render 'my_mailer/booking_success' }
    end

  end

  def notify_friend(email, booking)
    email = 'a17877yun@gmail.com,u9523039@yuntech.edu.tw'
    email = email.split(',')
    @booking = booking
    mail(to: email,
         subject: '訂吧通知：您的朋友邀請您一起用餐！') do |format|
      format.html { render 'my_mailer/booking_friend' }
    end
  end

  def cancel_booking(email, booking)
    email = 'a17877yun@gmail.com'

    @booking = booking
    mail(to: email,
         subject: '訂吧通知：您的訂位已取消！') do |format|
      format.html { render 'my_mailer/cancel_booking' }
    end
  end

end
