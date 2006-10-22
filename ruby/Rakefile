require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'

def announce(msg='')
  STDERR.puts msg
end

PKG_NAME = 'ruby-nxt'
PKG_VERSION = ENV['VERSION']

spec = Gem::Specification.new do |s|
  s.name      = PKG_NAME
  s.version   = PKG_VERSION
  s.author    = "Tony Buser"
  s.email     = "gr0k@rubyforge.org"
  s.homepage  = "#{PKG_NAME}.rubyforge.org"
  s.platform  = Gem::Platform::RUBY
  s.summary   = "Provides a Ruby interface to LEGO Mindstorms NXT"
  s.files     = Dir.glob("{test,examples,lib,doc}/**/*").delete_if {|item| item.include?(".svn") }
  s.require_path  = "lib"
  s.has_rdoc      = true
  s.extra_rdoc_files = ["README", "LICENSE"]
  s.rdoc_options << "--main" << 'README' << "--title" << "'ruby-nxt RDoc'" << "--line-numbers"
  s.rubyforge_project = PKG_NAME
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |p|
  p.main = "README"
  p.rdoc_dir = "doc"
  p.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  p.options << "--main" << 'README' << "--title" << "ruby-nxt RDoc" << "--line-numbers"
end

desc "Publish the API documentation"
task :pubrdoc => [ :rdoc ] do
  Rake::SshDirPublisher.new(
    "#{ENV['USER']}@rubyforge.org",
    "/var/www/gforge-projects/#{PKG_NAME}/",
    "doc" ).upload
end

desc "Create a new release"
task :release => [ :clobber, :package, :tag ] do
  announce 
  announce "**************************************************************"
  announce "* Release #{PKG_VERSION} Complete."
  announce "* Packages ready to upload."
  announce "**************************************************************"
  announce 
end

desc "Tag code"
Rake::Task.define_task("tag") do |p|
  baseurl = "svn+ssh://#{ENV['USER']}@rubyforge.org//var/svn/#{PKG_NAME}"
  sh "svn cp -m 'tagged #{ PKG_VERSION }' . #{ baseurl }/tags/REL-#{ PKG_VERSION }"
end

desc "Branch code"
Rake::Task.define_task("branch") do |p|
  baseurl = "svn+ssh://#{ENV['USER']}@rubyforge.org/var/svn/#{PKG_NAME}"
  sh "svn cp -m 'branched #{ PKG_VERSION }' #{baseurl}/trunk #{ baseurl }/branches/RB-#{ PKG_VERSION }"
end
