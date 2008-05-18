class UserMailer < Merb::MailController
  
  def signup
    @user = params[:user]
    render_mail
  end
  
  def activation
    @user = params[:user]
    render_mail
  end
  
  def forgot_password
    @user = params[:user]
    render_mail
  end

  def reset_password
    @user = params[:user]
    render_mail
  end
end