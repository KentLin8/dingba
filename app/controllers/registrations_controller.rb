class RegistrationsController < Devise::RegistrationsController
  layout 'restaurant_manage'

  def restaurant_new
  end

  def restaurant_create
    begin
      name = params[:tag_name].strip
      email = params[:tag_email].strip
      phone = params[:tag_phone].strip
      password = params[:tag_password].strip
      i_agree = params[:tag_i_agree].strip    # nil mean not agree clause

      if (name.blank? || email.blank? || phone.blank? || password.blank? || i_agree.blank?)
        flash.now[:alert] = '有欄位未填喔!'
        render 'devise/registrations/restaurant_new'
        return
      end

      if (email =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
        flash.now[:alert] = 'E-mail 格式錯誤!'
        render 'devise/registrations/restaurant_new'
        return
      end

      if i_agree != '1'
        flash.now[:alert] = '資料異常! 註冊失敗!'
        render 'devise/registrations/restaurant_new'
        return
      end

      person =  { 'name' => name,
                  'email' => email,
                  'phone' => phone,
                  'role' => 0,             # 0 = restaurant
                  'password' => password,
                  'password_confirmation' => password }

      user_id = devise_save(person)

      if user_id.blank?
        flash.now[:alert] = '發生錯誤! 註冊失敗!'
        render 'devise/registrations/restaurant_new'
      else
        restaurant_init(phone, user_id)
        #render json: {:success => true, :data => 'Please comfirm email!'}
      end
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/registrations_controller.rb ,Action:restaurant_create"
      flash.now[:alert] = '發生錯誤! 註冊失敗!'
      render 'devise/registrations/restaurant_new'
    end

  end

  def booker_new
  end

  def booker_create

    name = params[:tag_name]
    email = params[:tag_email]
    phone = params[:tag_phone]
    password = params[:tag_password]
    i_agree = params[:tag_i_agree]    # nil mean not agree clause

    if (name.blank? || email.blank? || phone.blank? || password.blank? || i_agree.blank?)
      flash.now[:alert] = '有欄位未填喔!'
      render 'devise/registrations/booker_new'
    else

      person =  { 'name' => name, 'email' => email, 'phone' => phone, 'role' => 1,   # 1 = booker
                  'password' => password, 'password_confirmation' => password }

      user_id = devise_save(person)

      if user_id.blank?
        flash.now[:alert] = '發生錯誤!'
      else
        #render json: {:success => true, :data => 'please comfirm email!'}
      end
    end

  end


  def devise_save(person)
    build_resource(person)

    if resource.save
      if resource.active_for_authentication?    # mabe lock
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :'signed_up_but_#{resource.inactive_message}' if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end

      return resource.id              #add by panda
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def restaurant_init(phone, user_id)
    begin
      Restaurant.transaction do
        # =================== res_url use integer increase
        #max_seq = Restaurant.maximum(:res_url)
        #
        #if max_seq.blank?
        #  max_seq = 0
        #end
        #
        #max_seq += 1
        #
        #res = Restaurant.new
        #res.phone = phone
        #res.res_url = max_seq         #APP_CONFIG['domain'] + res_store?res=00000001
        #res.save!
        #
        #res_user = RestaurantUser.new
        #res_user.restaurant_id = res.id
        #res_user.permission = 0       # 0 mean all manger
        #res_user.user_id = user_id
        #res_user.save!
        # =====================================================

        res_url_tag = get_res_url_tag
        res = Restaurant.new
        res.phone = phone
        res.res_url = res_url_tag         # APP_CONFIG['domain']
        res.available_type = '1'
        res.available_date = '22:00'
        res.save!

        res_user = RestaurantUser.new
        res_user.restaurant_id = res.id
        res_user.permission = 0           # 0 mean all manager
        res_user.user_id = user_id
        res_user.save!
      end
    rescue => e
      Rails.logger.error "#{e.message}"
    end
  end

  def get_res_url_tag
    rand_string = SecureRandom.hex(3)
    check = Restaurant.where(:res_url => rand_string)

    if check.blank?
      return rand_string
    else
      get_res_url_tag
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if update_resource(resource, registration_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def registration_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :current_password)
  end
end