#!/usr/bin/env ruby -w
# example code showing how to make a drb server to communicate with nxt

require File.dirname(File.expand_path(__FILE__))+'/../lib/nxt_comm'
require 'drb'

$DEBUG = true
$DEV = '/dev/tty.NXT-DevB-1'

DRb.start_service nil, NXTComm.new($DEV)
puts DRb.uri

DRb.thread.join
