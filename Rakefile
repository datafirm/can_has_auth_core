# -*- ruby -*-
 
require "rake"
require "rake/clean"
require "rake/gempackagetask"
require 'rake/rdoctask'
require "spec"
require "spec/rake/spectask"
 
DIR = File.dirname(__FILE__)
NAME = 'can_has_auth'
SUMMARY =<<-EOS
Drop in user authentication for merb with datamapper
EOS
 
require "lib/can_has_auth_core/version"
 
spec = Gem::Specification.new do |s|
  s.name = "can_has_auth_core"
  s.version = "0.1.0"
  s.date = "2008-05-12"
  s.summary = "Drop in authentication for merb and dm-core 0.9.x"
  s.email = "brian@downtowncartel.com"
  s.homepage = "http://github.com/BrianTheCoder/can_has_auth_core/tree/master"
  s.description = "can_has_auth_core gives you basic authentication for merb using the latest trunk of dm-core"
  s.has_rdoc = false
  s.authors = ["Brian Smith"]
  s.files = %w(
    License.txt
    Manifest.txt
    README.txt
    Rakefile
    config/hoe.rb
    config/requirements.rb
    lib/can_has_auth_core.rb
    lib/can_has_auth_core/version.rb
    lib/can_has_auth_core/models/user.rb
    lib/can_has_auth_core/controllers/users.rb
    lib/can_has_auth_core/controllers/session.rb
    lib/can_has_auth_core/controllers/password.rb
    lib/can_has_auth_core/auth_model.rb
    lib/can_has_auth_core/auth_controller.rb
    lib/can_has_auth_core/mailers/user_mailer.rb
    lib/can_has_auth_core/views/session/new.html.erb
    lib/can_has_auth_core/views/users/new.html.erb
    lib/can_has_auth_core/views/users/activate.html.erb
    lib/can_has_auth_core/views/password/new.html.erb
    lib/can_has_auth_core/views/password/edit.html.erb
    lib/can_has_auth_core/views/password/reset.html.erb
    lib/can_has_auth_core/views/users/activate.html.erb
    lib/can_has_auth_core/mailers/views/user_mailer/signup.html.erb
    lib/can_has_auth_core/mailers/views/user_mailer/signup.text.erb
    lib/can_has_auth_core/mailers/views/user_mailer/activation.html.erb
    lib/can_has_auth_core/mailers/views/user_mailer/activation.text.erb
    lib/can_has_auth_core/mailers/views/user_mailer/reset_password.html.erb
    lib/can_has_auth_core/mailers/views/user_mailer/reset_password.text.erb
    lib/can_has_auth_core/mailers/views/user_mailer/forgot_password.html.erb
    lib/can_has_auth_core/mailers/views/user_mailer/forgot_password.text.erb
    spec/application.rb
    spec/authenticated_system_spec_helper.rb
    spec/spec_helper.rb
    spec/user_spec_helper.rb
    spec/controllers/password_spec.rb
    spec/controllers/users_spec.rb
    spec/controllers/session_spec.rb
    spec/models/user_spec.rb
    setup.rb
  )
  s.test_files = %w(
    spec/application.rb
    spec/authenticated_system_spec_helper.rb
    spec/spec_helper.rb
    spec/user_spec_helper.rb
    spec/controllers/password_spec.rb
    spec/controllers/users_spec.rb
    spec/controllers/session_spec.rb
    spec/models/user_spec.rb
  )
  s.extra_rdoc_files = ["Manifest.txt", "README.txt"]
end
 
Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
  package.need_zip = true
  package.need_tar = true
end

desc "Run all specs"
Spec::Rake::SpecTask.new("specs") do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir["spec/**/*_spec.rb"].sort
end
