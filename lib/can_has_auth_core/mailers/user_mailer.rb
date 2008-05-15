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
  
  private
    alias :_orig_template_location :_template_location
  
    def _template_location(action, type = nil, controller = controller_name)
      file = controller == "layout" ? "layout.#{type}" : "#{action}.#{type}"
    
      unless Dir["#{Merb.dir_for(:mailer)}/views/#{controller}/#{action}.#{type}.*"].empty?
        _orig_template_location( action, type, controller )
      else
        undo   = Merb.load_paths[:view].first.gsub(%r{[^/]+}, '..')
        prefix = File.dirname(__FILE__)
        folder = 'views'
        File.join( '.',undo, prefix,folder, controller, file )
      end
    end
end