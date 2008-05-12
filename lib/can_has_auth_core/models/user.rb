require 'digest/sha1'
require File.join(File.dirname(__FILE__),'..','auth_model')

class User
  include DataMapper::Resource
  include AuthModel
  
  attr_accessor :password, :password_confirmation
  
  property :id,                         Fixnum, :serial => true
  property :email,                      String, :length => 3..100, :nullable => false, :unique => true
  property :crypted_password,           String
  property :salt,                       String
  property :activation_code,            String
  property :activated_at,               DateTime
  property :remember_token_expires_at,  DateTime
  property :remember_token,             String
  property :password_reset_code,        String
  property :created_at,                 DateTime
  property :updated_at,                 DateTime
  
  validates_present           :password,                :if => :password_required?
  validates_present           :password_confirmation,   :if => :password_required?
  validates_length            :password,                :within => 4..40, :if => :password_required?
  validates_is_confirmed      :password,                :groups => :create
    
  before :save, :encrypt_password
  before :save, :make_activation_code
  after :save, :send_signup_notification
  
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
    save
    send_activation
  end
  
  def send_activation
    deliver_email(:activation, :subject => "Welcome to MYSITE.  Please activate your account.")
  end
  
  def send_signup_notification
    if recently_created?
      deliver_email(:signup, :subject => "Welcome to MYSITE")
      @created = false
    end
  end
  
  def send_forgot_password
    deliver_email(:forgot_password, :subject => "Request to change your password")
  end
  
  def send_reset_password
    deliver_email(:reset_password, :subject => "Your password has been reset")
  end  
  
  def deliver_email(action, params)
    from = "info@mysite.com"
    UserMailer.dispatch_and_deliver(action, params.merge(:from => from, :to => self.email), :user => self)
  end
  
end