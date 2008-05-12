class Password < Application
  before :login_required, :only => [:edit,:update]
  
  def new
    render
  end
  
  def create(email)
    if @user = User.first(:email => email)
      @user.forgot_password
      @user.save
    end
    redirect url(:login)
  end

  def edit
    @user = self.current_user
    display @user
  end
  
  def reset
    @user = User.first(:password_reset_code => params[:code])
    if @user.nil?
      redirect_back_or_default('/')
    else
      self.current_user = @user
      render
    end
  end

  def update(user)
    @user = self.current_user.password_reset_code.nil? ? User.authenticate(current_user.email, params[:old_password]): self.current_user	
    unless @user.nil?
      @user.update_attributes(user)
      if @user.save
        @user.reset_password unless @user.password_reset_code.nil?
        redirect_back_or_default('/')
      else
        render :edit
      end
    else
      redirect url(:edit_password)
    end
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
