class ConfirmationsController < Devise::ConfirmationsController

  def resend_confirm_email
    self.resource = resource_class.new
    render :layout => false
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){
        if resource.role == '0'
          redirect_to confirmation_getting_started_path      # TODO user and restaurant
        else
          redirect_to booker_manage_index_path
        end
      }
    else
      # sessions destroy
      # comfirm again error

      if !resource.confirmation_token.blank?
        x = User.where(:confirmation_token => resource.confirmation_token).first
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        sign_in(resource_name, x)
        respond_with_navigational(x){
          if x.role == '0'
            redirect_to confirmation_getting_started_path      # TODO user and restaurant
          else
            redirect_to booker_manage_index_path
          end
        }

      else
        redirect_path = after_sign_out_path_for(resource_name)
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
        yield resource if block_given?

        respond_to do |format|
          format.all { head :no_content }
          format.any(*navigational_formats) { redirect_to redirect_path }
        end
      end


      #respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render_with_scope :new } # TODO render_with_scope ,error handle
    end
  end

end