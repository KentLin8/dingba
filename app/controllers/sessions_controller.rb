class SessionsController < Devise::SessionsController
  layout 'restaurant_manage'

  def restaurant_new
    new(sign_in_params)
  end

  def booker_new
    new(sign_in_params)
  end

  def new(sign_in_params)
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    redirect_to after_sign_in_path_for(resource)
    #respond_with resource, :location => after_sign_in_path_for(resource)
  end

end