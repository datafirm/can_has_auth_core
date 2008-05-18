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
end