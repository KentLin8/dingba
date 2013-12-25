class RegistrationsController < Devise::RegistrationsController
  layout 'restaurant_manage'

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # GET ==== Function: show registration restaurant view
  # =========================================================================
  def restaurant_new
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: TODO: phase 2]
  # POST === Function: create restaurant role user
  # =========================================================================
  def restaurant_create
    begin
      user_create('devise/registrations/restaurant_new', '0')
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/registrations_controller.rb ,Action:restaurant_create"
      flash.now[:alert] = '發生錯誤! 註冊失敗!'
      render 'devise/registrations/restaurant_new'
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # GET ==== Function: show registration booker view
  # =========================================================================
  def booker_new
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # POST === Function: create booker role user
  # =========================================================================
  def booker_create
    begin
      user_create('devise/registrations/booker_new', '1')
    rescue => e
      Rails.logger.error APP_CONFIG['error'] + "(#{e.message})" + ",From:app/controllers/registrations_controller.rb ,Action:booker_create"
      flash.now[:alert] = '發生錯誤! 註冊失敗!'
      render 'devise/registrations/restaurant_new'
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # Method === Function: validation params and save user
  # =========================================================================
  def user_create(from_url, role)
    name = params[:tag_name].strip
    email = params[:tag_email].strip
    phone = params[:tag_phone].strip
    password = params[:tag_password].strip
    i_agree = params[:tag_i_agree].strip    # nil mean not agree clause

    if (name.blank? || email.blank? || phone.blank? || password.blank? || i_agree.blank?)
      flash.now[:alert] = '有欄位未填喔!'
      render from_url
      return
    end

    if (email =~ /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/).blank?
      flash.now[:alert] = 'E-mail 格式錯誤!'
      render from_url
      return
    end

    if i_agree != '1'
      flash.now[:alert] = '資料異常! 註冊失敗!'
      render from_url
      return
    end

    person =  { 'name' => name,
                'email' => email,
                'phone' => phone,
                'role' => role,              # 0 = restaurant, 1 = booker
                'password' => password,
                'password_confirmation' => password }

    devise_save(person)
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: TODO: detail review ]
  # Method === Function: save user
  # =========================================================================
  def devise_save(person)
    User.transaction do
      build_resource(person)
      if resource.save
        if person['role'] == '0'
          restaurant_init(person['phone'], resource.id)
        end

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :'signed_up_but_#{resource.inactive_message}' if is_navigational_format?
          expire_session_data_after_sign_in!
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        respond_with resource
      end
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # Method === Function: init restaurant data
  # =========================================================================
  def restaurant_init(phone, user_id)
    # max_seq = Restaurant.maximum(:res_url)
    res_url_tag = get_res_url_tag
    res = Restaurant.new
    res.phone = phone
    res.res_url = res_url_tag         # APP_CONFIG['domain']
    res.available_type = '1'
    res.available_date = '22:00'
    res.save

    res_user = RestaurantUser.new
    res_user.restaurant_id = res.id
    res_user.permission = 0           # 0 mean all manager
    res_user.user_id = user_id
    res_user.save
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: ok ]
  # Method === Function: get restaurant url tag
  # =========================================================================
  def get_res_url_tag
    rand_string = SecureRandom.hex(3)
    check = Restaurant.where(:res_url => rand_string)

    if check.blank?
      return rand_string
    else
      get_res_url_tag
    end
  end

  # ====== Code Check: 2013/12/25 ====== [ panda: TODO: detail review ]
  # POST === Function: update user data
  # =========================================================================
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