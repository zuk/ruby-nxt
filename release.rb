#!/usr/bin/env ruby -w

# Probably a better way to do this... should also make an svn tag or something

version = ARGV[0]

if version.nil?
  puts "Usage: #{__FILE__} [version]"
  exit
end

system "rm ruby/log/*.log"
system "zip -qr ruby-nxt-#{version}.zip ruby/* -x \\*.svn*"
system "tar --exclude '*/.*' --exclude 'LICENSE.*' -zc ruby -f ruby-nxt-#{version}.tar.gz"
