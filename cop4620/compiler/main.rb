# $debug = 1
require File.join(File.dirname(__FILE__), './context')
require File.join(File.dirname(__FILE__), './a1')
require File.join(File.dirname(__FILE__), './constants')
require File.join(File.dirname(__FILE__), './a2_transitions')
require File.join(File.dirname(__FILE__), './a2')
require File.join(File.dirname(__FILE__), './a4')

input = File.open(ARGV[0], 'r')
begin
  puts A4.new(input.readlines.join("")).to_s
rescue
  puts "REJECT"
end
