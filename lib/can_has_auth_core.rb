$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

base = File.dirname(__FILE__)
name = "can_has_auth"

if defined?(Merb::Plugins)
  require "merb_helpers"
  require "merb-mailer"
  require "merb-action-args"

  Merb::BootLoader.before_app_loads do
    class Merb::Controller 
      self._template_roots << [File.join(File.dirname(__FILE__), 'can_has_auth_core','views'), :_template_location]
      self._template_roots << [File.join(File.dirname(__FILE__), 'can_has_auth_core','mailers','views'), :_template_location]
    end

    if Merb.env == "development"
      Merb::Mailer.delivery_method = :test_send
    else
      Merb::Mailer.delivery_method = :net_smtp
    end
    Merb::Plugins.config[name.to_sym] = {}
  end

  Merb::BootLoader.after_app_loads do
    require 'can_has_auth_core/auth_controller'
    require 'can_has_auth_core/models/user'
    require 'can_has_auth_core/controllers/session'
    require 'can_has_auth_core/controllers/users'
    require 'can_has_auth_core/controllers/password'
    require 'can_has_auth_core/mailers/user_mailer'
    Merb::Router.prepend do |r|
      r.match("/login",:method => :get).to(:controller => "session", :action => "new").name(:login)
      r.match("/login",:method => :post).to(:controller => "session", :action => "create").name(:login)
      r.match("/logout").to(:controller => "session", :action => "destroy").name(:logout)
      r.match("/users/activate/:activation_code").to(:controller => "users", :action => "activate").name(:user_activation)
      r.match("/signup").to(:controller => "users", :action => "new").name(:signup)
      r.match("/password/reset").to(:controller => "password", :action => "reset").name(:reset_password)
      r.match("/password/new").to(:controller => "password", :action => "new").name(:new_password)
      r.match("/password/edit").to(:controller => "password", :action => "edit").name(:edit_password)
      r.match("/password", :method => :post).to(:controller => "password", :action => "create").name(:password)
      r.match("/password", :method => :put).to(:controller => "password", :action => "update").name(:password)
      r.resources :users
    end
    Application.send(:include, AuthController)
  end
end


class DateTime
  def to_time
    Time.parse(self.to_s)
  end
  
  def gmtime
    self.to_time.gmtime
  end
end