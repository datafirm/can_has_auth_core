require File.join(File.dirname(__FILE__), "..", "spec_helper")
require File.join( File.dirname(__FILE__), "..", "user_spec_helper")
require File.join( File.dirname(__FILE__), "..", "authenticated_system_spec_helper")

describe "Session Controller", "new action" do
  include UserSpecHelper
  
  it "should respond successfully" do
    dispatch_to(Session, :new).should respond_successfully
  end
end

describe "Session Controller", "login action" do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @quentin = User.create(valid_user_hash.with(:email => "quentin@example.com", :password => "test", :password_confirmation => "test"))
    @quentin.activate
  end
  
  it 'logins and redirects' do
    controller = dispatch_to(Session, :create, :email => 'quentin@example.com', :password => 'test')
    controller.session[:user].should_not be_nil
    controller.session[:user].should == @quentin.id
    controller.should redirect_to("/")
  end
   
  it 'fails login and does not redirect' do
    controller = dispatch_to(Session, :create, :method => :post, :email => 'quentin@example.com', :password => 'bad password')
    controller.should respond_successfully
    controller.session[:user].should be_nil
  end
  
  it 'remembers me' do
    controller = dispatch_to(Session,:create, :method => :post, :email => 'quentin@example.com', :password => 'test', :remember_me => "1")
    controller.cookies["auth_token"].should_not be_nil
    controller.should redirect
  end
 
  it 'does not remember me' do
    controller = dispatch_to(Session, :create,:method => :post, :email => 'quentin@example.com', :password => 'test', :remember_me => "0")
    controller.cookies["auth_token"].should be_nil
    controller.should redirect
  end
  
  it 'logs in with cookie' do
    @quentin.remember_me
    controller = get "/login" do |c|
      c.request.env[Merb::Const::HTTP_COOKIE] = "auth_token=#{@quentin.remember_token}"
    end
    controller.should be_logged_in
  end
end

describe "Session Controller", "logout action" do
  include UserSpecHelper
  
  before(:each) do
    User.auto_migrate!
    @quentin = User.create(valid_user_hash.with(:email => "quentin@example.com", :password => "test", :password_confirmation => "test"))
    @quentin.activate
  end
  
  it 'logs out' do
    controller = dispatch_to(Session, :destroy) do
      self.stub!(:current_user).and_return(@quentin)
    end
    controller.session[:user].should be_nil
    controller.should redirect
  end
  
  it 'deletes token on logout' do
    controller = dispatch_to(Session, :destroy) do
      self.stub!(:current_user).and_return(@quentin)
    end
    controller.cookies["auth_token"].should == nil
    controller.should redirect
  end
end
  
describe "Session Controller", "routes" do

  it "routed to Session#new from '/login'" do
    request = request_to("/login")
    request[:controller].should == "session"
    request[:action].should == "new"
  end
  
  it "routed to Session#create from '/login' via :post" do
    request = request_to("/login", :post)
    request[:controller].should  == "session"
    request[:action].should      == "create"      
  end
  
  it "routed to Session#destroy from '/logout' via :get" do
    request = request_to("/logout")
    request[:controller].should == "session" 
    request[:action].should     == "destroy"
  end
  
  it "routed to Session#destroy from '/logout' via :delete" do
    request = request_to("/logout", :delete)
    request[:controller].should == "session"
    request[:action].should    == "destroy"
  end
end

def auth_token(token)
  CGI::Cookie.new('name' => 'auth_token', 'value' => token)
end
  
def cookie_for(user)
  auth_token user.remember_token
end
