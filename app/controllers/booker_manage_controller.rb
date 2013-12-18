class BookerManageController < ApplicationController
  layout 'booker_manage'
  before_action :get_booker, :only => [:index, :booking_record, :feedback, :account]

  def index
    @books = Booking.where(:user_id => @booker.id).order('booking_time DESC')
  end

  def booking_record
    @books = Booking.where(:user_id => @booker.id).order('booking_time DESC')
  end

  def feedback
    result = BookerManage.save_feedback(params[:booking_id], params[:feedback])
    render json: result
  end

  def get_booker
    begin
      if current_user.blank?
        flash.now[:alert] = '您還沒登入喔!~~ '
        redirect_to booker_session_new_path
      else
        @booker = User.where(:id => current_user.id, :role => '1').first

        if @booker.blank?
          Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/booker_manage_controller.rb  ,Filter:get_booker"
          redirect_to booker_session_new_path
        end
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/booker_manage_controller.rb  ,Filter:get_booker"
      flash.now[:alert] = 'oops! 出現錯誤了!'
      redirect_to booker_session_new_path
    end
  end

end
