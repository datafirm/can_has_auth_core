class Users < Application
  provides :xml
  
  skip_before :login_required
  
  def new
    only_provides :html
    @user = User.new(params[:user] || {})
    display @user
  end
  
  def create(user)
    cookies.delete :auth_token
    @user = User.new(user)
    if @user.save
      redirect_back_or_default('/')
    else
      render :new
    end
  end
  
  def activate
    self.current_user = User.first(:activation_code => params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      redirect_back_or_default('/')
    else
      render
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