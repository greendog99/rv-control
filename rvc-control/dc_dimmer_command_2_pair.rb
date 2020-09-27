#!/usr/bin/env ruby
#
# Send a pair of DC_DIMMER_COMMAND_2 commands (off/on)
#
# See RV-C Specification, Table 6.25.6a

require 'optparse'

options = {}
OptionParser.new do |opts|
  options[:duration] = 30

  opts.on('-i', '--instance NUM', Integer, '[REQUIRED] Primary instance to control')
  opts.on('-a', '--alternate NUM', Integer, '[REQUIRED] Alternate instance to control')
  opts.on('-d', '--duration NUM', Integer, 'Duration of command')
  opts.on('-h', '--help', 'Display this screen' ) do
    puts opts
    puts "\nCommon commands:\n"
    exit
  end
end.parse!(into: options)

if (options[:instance].nil? || options[:alternate].nil?)
  raise OptionParser::MissingArgument.new("instance and alternate are required arguments")
end

dgn = '1FEDB'
pri = '0x6'
src = '0x99'

# Commands are hex, but since they are less than 10, no conversion is needed.
stop_command = 3        # 0x03 OFF: Set dimmer brightness directly to 0%
stop_brightness = 0
stop_delay = 0

start_command = 5       # 0x05 Toggle: Toggle brightness between 0% and desired value
start_brightness = 200  # 0xC8 = 200 in 1/2% increments

bits = sprintf('%b0%b%b', pri.to_i(16), dgn.to_i(16), src.to_i(16))
hex_id = bits.to_i(2).to_s(16)

# Stop the alternate instance
hex_data = sprintf('%02xFF%02x%02x%02x00FFFF',
                   options[:alternate].to_i,
                   stop_brightness,
                   stop_command,
                   stop_delay)
puts "cansend can0 #{hex_id}##{hex_data}"
# system "cansend can0 #{hex_id}##{hex_data}"

# Start the primary instance
hex_data = sprintf('%02xFF%02x%02x%02x00FFFF',
                   options[:instance].to_i,
                   start_brightness,
                   start_command,
                   options[:duration].to_i)
puts "cansend can0 #{hex_id}##{hex_data}"
# system "cansend can0 #{hex_id}##{hex_data}"

