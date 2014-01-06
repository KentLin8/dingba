
class PasswordsController < Devise::PasswordsController
  #layout 'home_index'

  def set_new_password
    self.resource = resource_class.new
    render :layout => false
  end
end