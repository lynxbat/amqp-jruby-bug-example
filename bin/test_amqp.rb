#!/usr/bin/env ruby

# Tests concurrent multi-threading handling with amqp

# Add lib to load path
lib_dir = File.dirname(File.expand_path(__FILE__)).sub(%r{bin$}, 'lib')
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

#
require 'em_bug'

trap('INT') do
  EMBug.kill_test
  exit
end

concurrent = ARGV[0].to_i rescue 1
concurrent = 1 if concurrent < 1

EMBug.run_amqp_test(
    :task_latency_min => 10,
    :task_latency_max => 15,
    :concurrency => concurrent,
    :node => 'mq01',
) do |q|
  #
end