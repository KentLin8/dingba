
class PasswordsController < Devise::PasswordsController
  #layout 'home_index'

  def set_new_password
    self.resource = resource_class.new
    render :layout => false
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash.now[:alert] = '重新設定密碼 E-Mail 已經寄出，麻煩前往收信'
      render 'devise/sessions/booker_new'
      return
    else
      user = self.resource
      if user.id.blank?
        flash.now[:alert] = '沒有此 E-Mail'
        render 'devise/sessions/booker_new'
        return
      else
        redirect_to booker_manage_index_path
      end
    end
  end
end


