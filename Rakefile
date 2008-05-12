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
 
require "lib/can_has_auth/version"
 
spec = Gem::Specification.new do |s|
  s.name = NAME
  s.summary = SUMMARY
 
  s.version = CanHasAuth::VERSION::STRING
  s.platform = Gem::Platform::RUBY
 
  s.require_path = "lib"
  s.files = %w(Rakefile LICENSE HISTORY README) + Dir["lib/**/*"]
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
