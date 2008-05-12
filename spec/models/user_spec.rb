require File.join( File.dirname(__FILE__), "..", "spec_helper" )
require File.join( File.dirname(__FILE__), "..", "user_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe User do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    UserMailer.stub!(:activation).and_return(true)
    @user = User.new(valid_user_hash)
  end
  
  it "should make a valid user" do
    @user.valid?.should be_true
    @user.errors.should be_empty
  end
  
  it "requires an email" do
    @user.email = nil
    @user.valid?.should be_false
    @user.errors.on(:email).should_not be_nil
    @user.errors.on(:email).should_not be_empty
  end
  
  it "requires a unique email" do
    @user.save
    new_user = User.new(valid_user_hash)
    new_user.valid?.should be_false
    new_user.errors.on(:email).should_not be_nil
    new_user.errors.on(:email).should_not be_empty
  end
  
end

describe User, "authenticate" do
  include UserSpecHelper
  
  before(:each) do
    UserMailer.stub!(:activation).and_return(true)
  end
  
  before(:all) do
    User.auto_migrate!
    @user = User.create(valid_user_hash)
    @user.activate
  end
  
  it "should authenticate a user using a class method" do
    User.authenticate(valid_user_hash[:email], valid_user_hash[:password]).should_not be_nil
    User.authenticate(valid_user_hash[:email], valid_user_hash[:password]).should == @user
  end
  
  it "should not authenticate a user using the wrong password" do 
    User.authenticate(valid_user_hash[:email], "not_the_password").should be_nil
  end
  
  it "should not authenticate a user using the wrong email" do
    User.authenticate("not_the_login", valid_user_hash[:password]).should be_nil
  end
  
  it "should not authenticate a user that does not exist" do
    User.authenticate("i_dont_exist", "password").should be_nil
  end
  
  it "should send a please activate email" do
    User.auto_migrate!
    user = User.new(valid_user_hash)
    UserMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :signup
      [:from, :to, :subject].each{ |f| mail_args.keys.should include(f)}
      mail_args[:to].should == user.email
      mailer_params[:user].should == user
    end
    user.save
  end
  
  it "should not send a please activate email when updating" do
    UserMailer.should_not_receive(:signup_notification)
    @user.update_attributes(:email =>"not in the valid hash for login")
  end
end

describe User, "the password fields for User" do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @user = User.new( valid_user_hash )
    UserMailer.stub!(:activation_notification).and_return(true)
  end
  
  it "should respond to password" do
    @user.should respond_to(:password)    
  end
  
  it "should respond to password_confirmation" do
    @user.should respond_to(:password_confirmation)
  end
  
  it "should have a protected password_required method" do
    @user.protected_methods.should include("password_required?")
  end
  
  it "should respond to crypted_password" do
    @user.should respond_to(:crypted_password)    
  end
  
  it "should require password if password is required" do
    user = User.new( valid_user_hash.without(:password))
    user.stub!(:password_required?).and_return(true)
    user.valid?
    user.errors.on(:password).should_not be_nil
    user.errors.on(:password).should_not be_empty
  end
  
  it "should set the salt" do
    user = User.new(valid_user_hash)
    user.salt.should be_nil
    user.send(:encrypt_password)
    user.salt.should_not be_nil    
  end
  
  it "should require the password on create" do
    user = User.new(valid_user_hash.without(:password))
    user.valid?.should be_false
    user.errors.on(:password).should_not be_nil
    user.errors.on(:password).should_not be_empty
  end  
  
  it "should require password_confirmation if the password_required?" do
    user = User.new(valid_user_hash.without(:password_confirmation))
    user.valid?.should be_false
    (user.errors.on(:password) || user.errors.on(:password_confirmation)).should_not be_nil
  end
  
  it "should fail when password is outside 4 and 40 chars" do
    [3,41].each do |num|
      user = User.new(valid_user_hash.with(:password => ("a" * num)))
      user.valid?
      user.errors.on(:password).should_not be_nil
    end
  end
  
  it "should pass when password is within 4 and 40 chars" do
    [4,30,40].each do |num|
      user = User.new(valid_user_hash.with(:password => ("a" * num), :password_confirmation => ("a" * num)))
      user.valid?
      user.errors.on(:password).should be_nil
    end    
  end
  
  it "should autenticate against a password" do
    user = User.create(valid_user_hash)
    user.should be_authenticated(valid_user_hash[:password])
  end
  
  it "should not require a password when saving an existing user" do
    user = User.create(valid_user_hash)
    user = User.first(:email => valid_user_hash[:email])
    user.password.should be_nil
    user.password_confirmation.should be_nil
    user.email = "some_different_login_to_allow_saving"
    user.save.should be_true
  end
  
end

describe User, "forgot password" do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @user = User.new(valid_user_hash)
  end
  
  it "should have a password_reset_code field" do
    @user.should respond_to(:password_reset_code)
  end
  
  it "should make a password reset code" do
    @user.forgot_password
    @user.recently_forgot_password?.should be_true
    @user.password_reset_code.should_not be_nil
  end
  
  it "should reset password reset code" do
    @user.reset_password
    @user.recently_reset_password?.should be_true
    @user.password_reset_code.should be_nil
  end
end

describe User, "activation" do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @user = User.new(valid_user_hash)
  end
  
  it "should have an activation_code as an attribute" do
    @user.attributes.has_key?(:activation_code).should be_true
  end
  
  it "should create an activation code on create" do
    @user.activation_code.should be_nil    
    @user.save
    @user.activation_code.should_not be_nil
  end
  
  it "should not be active when created" do
    @user.should_not be_activated
    @user.save
    @user.should_not be_activated    
  end
  
  it "should respond to activate" do
    @user.should respond_to(:activate)    
  end
  
  it "should activate a user when activate is called" do
    @user.should_not be_activated
    @user.save
    @user.activate
    @user.should be_activated
    User.first(:email => valid_user_hash[:email]).should be_activated
  end
  
  it "should should show recently activated when the instance is activated" do
    @user.should_not be_recently_activated
    @user.activate
    @user.should be_recently_activated
  end
  
  it "should not show recently activated when the instance is fresh" do
    @user.activate
    @user = nil
    User.first(:email => valid_user_hash[:email]).should_not be_recently_activated
  end
  
  it "should send out a welcome email to confirm that the account is activated" do
    @user.save
    UserMailer.should_receive(:dispatch_and_deliver) do |action, mail_args, mailer_params|
      action.should == :activation
      mail_args.keys.should include(:from)
      mail_args.keys.should include(:to)
      mail_args.keys.should include(:subject)
      mail_args[:to].should == @user.email
      mailer_params[:user].should == @user
    end
    @user.activate
  end
  
end

describe User, "remember_me" do
  include UserSpecHelper
  
  predicate_matchers[:remember_token] = :remember_token?
  
  before do
    User.auto_migrate!
    @user = User.new(valid_user_hash)
  end
  
  it "should have a remember_token_expires_at attribute" do
    @user.attributes.has_key?(:remember_token_expires_at).should be_true
  end
  
  it "should respond to remember_token?" do
    @user.should respond_to(:remember_token?)
  end
  
  it "should return true if remember_token_expires_at is set and is in the future" do
    @user.remember_token_expires_at = DateTime.now + 3600
    @user.should remember_token    
  end
  
  it "should set remember_token_expires_at to a specific date" do
    time = DateTime.new(2009,12,25)
    @user.remember_me_until(time)
    @user.remember_token_expires_at.should == time    
  end
  
  it "should set the remember_me token when remembering" do
    time = DateTime.new(2009,12,25)
    @user.remember_me_until(time)
    @user.remember_token.should_not be_nil
    @user.save
    User.first(:email => valid_user_hash[:email]).remember_token.should_not be_nil
  end
  
  it "should remember me for" do
    t = DateTime.now
    DateTime.stub!(:now).and_return(t)
    today = DateTime.now
    remember_until = today + 14
    @user.remember_me_for(14)
    @user.remember_token_expires_at.should == (remember_until)
  end
  
  it "should remember_me for two weeks" do
    t = DateTime.now
    DateTime.stub!(:now).and_return(t)
    @user.remember_me
    @user.remember_token_expires_at.should == (DateTime.now + 14)
  end
  
  it "should forget me" do
    @user.remember_me
    @user.save
    @user.forget_me
    @user.remember_token.should be_nil
    @user.remember_token_expires_at.should be_nil    
  end
  
  it "should persist the forget me to the database" do
    @user.save
    @user.remember_me   
    @user = User.first(:email => valid_user_hash[:email])
    @user.remember_token.should_not be_nil
    @user.forget_me
    @user = User.first(:email => valid_user_hash[:email])
    @user.remember_token.should be_nil
    @user.remember_token_expires_at.should be_nil
  end
  
end

# describe User, "friendships" do
#   include UserSpecHelper
#   
#   before do
#     User.auto_migrate!
#     @user = User.new(valid_user_hash)
#   end
#   
#   it "responds to my_friends" do
#     @user.should respond_to(:my_friends)
#   end
#   
#   it "responds to friends_of" do
#     @user.should respond_to(:friends_of)
#   end
#   
#   it "responds to pending_friends" do
#     @user.should respond_to(:pending_friends)
#   end
# end