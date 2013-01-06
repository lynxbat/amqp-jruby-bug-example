#!/usr/bin/env ruby

# Tests concurrent multi-threading handling with em alone

# Add lib to load path
lib_dir = File.dirname(File.expand_path(__FILE__)).sub(%r{bin$}, 'lib')
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

#
require 'em_bug'

trap('INT') do
  EMBug.kill_test
  exit
end

EMBug.run_em_test(
    :task_latency_min => 10,
    :task_latency_max => 15,
    :concurrency => ARGV.first.to_i,
    :events_per_sec => 1000000,
) do |q|
  #
end