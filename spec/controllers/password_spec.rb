require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "user_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe Password,"new action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
  end
  
  it "should get new" do
    dispatch_to(Password, :new).should respond_successfully
  end  
end

describe Password, "create action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @user = User.create(valid_user_hash)
    @user.save
    @user.activate
  end
  
  it "should forget password for valid email" do
    controller = dispatch_to(Password, :create, :email => valid_user_hash[:email])
    controller.should redirect
    user = User.first(:email => valid_user_hash[:email])
    user.password_reset_code.should_not be_nil
  end
  
  it "should not forget password for invalid email" do
    controller = dispatch_to(Password, :create, :email => "foo@bar.com")
    controller.should redirect
    @user.password_reset_code.should be_nil
  end
end

describe Password, "edit action" do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @user = User.create(valid_user_hash)
    @user.activate
  end
  
  it "a login is required for edit" do
    dispatch_to(Password, :edit).should redirect
  end
  
  it "should render edit" do
    controller = dispatch_to(Password, :edit) do |controller|
      controller.stub!(:current_user).and_return(@user)
    end
    controller.should respond_successfully
  end
end

describe Password, "update action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @user = User.create(valid_user_hash)
    @user.activate
    @pass = "newpassword"
  end
  
  def dispatch_update(params)
    dispatch_to(Password, :update, params) do |controller|
      controller.stub!(:current_user).and_return(@user)
    end
  end
  
  it "resets the password" do
    @user.forgot_password
    controller = dispatch_update(:user => {:password => @pass, :password_confirmation => @pass}) 
    controller.should redirect
    User.authenticate(valid_user_hash[:email], @pass).should == User.first(:email => valid_user_hash[:email])
  end
  
  it "changes the password" do
    controller = dispatch_update(:old_password => valid_user_hash[:password], :user => {:password => @pass, :password_confirmation => @pass})
    controller.should redirect
    User.authenticate(valid_user_hash[:email], @pass).should == User.first(:email => valid_user_hash[:email])
  end
  
  it "passwords must match" do
    controller = dispatch_update(:old_password => 'test', :user => {:password => @pass, :password_confirmation => 'test' })
    controller.should redirect
    User.authenticate(valid_user_hash[:email], @pass).should_not == User.first(:email => valid_user_hash[:email])
  end
  
  it "old password must be correct" do
    controller = dispatch_update(:old_password => 'wrong',:user => {:password => @pass, :password_confirmation => @pass} )
    controller.should redirect
    User.authenticate(valid_user_hash[:email], @pass).should_not == User.first(:email => valid_user_hash[:email])
  end
end

describe Password,"reset action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
  end
  
  it "should redirect to / if password code is nil" do
    dispatch_to(Password, :reset).should redirect_to('/')
  end
  
  it "should render if there's a valid password reset code" do
    user = User.create(valid_user_hash)
    user.activate
    user.forgot_password
    user.save
    controller = dispatch_to(Password, :reset, :code => user.password_reset_code)
    controller.should respond_successfully
  end
end

describe Password, "routes" do
  it "routed to Password#reset from 'password/reset'" do
    request = request_to("/password/reset")
    request[:controller].should == "password"
    request[:action].should == "reset"
  end
  
  it "routed to Password#new from 'password/new'" do
    request = request_to("/password/new")
    request[:controller].should == "password"
    request[:action].should == "new"
  end
  
  it "routed to Password#reset from 'password/edit'" do
    request = request_to("/password/edit")
    request[:controller].should == "password"
    request[:action].should == "edit"
  end
  
  it "routed to Password#reset from 'password/create' via :post" do
    request = request_to("/password", :post)
    request[:controller].should == "password"
    request[:action].should == "create"
  end
  
  it "routed to Password#reset from 'password/update' via :put" do
    request = request_to("/password", :put)
    request[:controller].should == "password"
    request[:action].should == "update"
  end
end
