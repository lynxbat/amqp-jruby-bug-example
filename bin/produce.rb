#!/usr/bin/env ruby


# Produces simple command events into a queue for testing

# Add lib to load path
lib_dir = File.dirname(File.expand_path(__FILE__)).sub(%r{bin$}, 'lib')
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

#
require 'em_bug'


count = ARGV[0].to_i rescue 10
count = 1 if count < 1
loop_size = ARGV[1].to_i rescue 1


trap('INT') do
  EMBug.kill_test
  exit
end

loop_size.times do
  EMBug.command_stage(:count => count, :node => 'mq01')
end