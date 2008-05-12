require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')
require File.join( File.dirname(__FILE__), "..", "user_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe Users, "new action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
  end
  
  it 'should respond successfully' do
    dispatch_to(Users, :new).should respond_successfully
  end
  
end

describe Users, "create action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
  end
  
  it 'allows signup' do
     lambda do
       controller = dispatch_to(Users, :create, :user => valid_user_hash)
       controller.should redirect      
     end.should change(User, :count).by(1)
  end
end

describe Users, "activate action" do
  
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
  end
  
  it 'should respond successfully' do
    dispatch_to(Users, :activate).should respond_successfully
  end
  
  it 'activates user' do
    user = {:login => "aaron", :password => "test", :password_confirmation => "test"}
    controller = dispatch_to(Users, :create, :user => valid_user_hash.merge(user))
    @user = controller.assigns(:user)
    User.authenticate('aaron', 'test').should be_nil
    controller = dispatch_to(Users, :activate, :activation_code => @user.activation_code)
    controller.should redirect
  end
end

describe Users, "routes" do
  it "routed to Users#activate from 'users/activate/1234'" do
    request = request_to("/users/activate/1234")
    request[:controller].should == "users"
    request[:action].should == "activate"
    request[:activation_code].should == "1234"
  end
  
  it "routed to Users#create from 'users' post" do
    request = request_to("/users", :post)
    request[:controller].should == "users"
    request[:action].should == "create"
  end
  
  it "routed to Users#new from 'users/new'" do
    request = request_to("/users/new")
    request[:controller].should == "users"
    request[:action].should == "new"
  end
  
  it "routed to Users#new from 'signup'" do
    request = request_to("/signup") 
    request[:controller].should == "users"
    request[:action].should == "new"
  end
end
