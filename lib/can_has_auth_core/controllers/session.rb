class Session < Application
  
  skip_before :login_required
  
  def new
    render
  end

  def create(email, password)
    self.current_user = User.authenticate(email, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , 
          :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
    else
      render :new
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end
  
  private
    alias :_orig_template_location :_template_location
  
    def _template_location(action, type = nil, controller = controller_name)
      file = controller == "layout" ? "layout.#{type}" : "#{action}.#{type}"
    
      unless Dir["#{Merb.dir_for(:view)}/#{controller}/#{action}.#{type}.*"].empty?
        _orig_template_location( action, type, controller )
      else
        undo   = Merb.load_paths[:view].first.gsub(%r{[^/]+}, '..')
        prefix = File.dirname(__FILE__)
        folder = 'views'
        File.join( '.',undo, prefix,'..', folder, controller, file )
      end
    end
end