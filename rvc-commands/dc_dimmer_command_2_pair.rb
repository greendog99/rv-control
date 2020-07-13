#!/usr/bin/env ruby
#
# Send a pair of DC_DIMMER_COMMAND_2 commands (off/on)

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

stop_command = 3
stop_brightness = 0
stop_delay = 0

start_command = 1
start_brightness = 100

# See RV-C Specification, section 3.2
# dgn_hi = dgn.slice(0..2)
# dgn_lo = dgn.slice(3..4)
# bits = sprintf('%b0%b%b%b', pri.to_i(16), dgn_hi.to_i(16), dgn_lo.to_i(16), src.to_i(16))

bits = sprintf('%b0%b%b', pri.to_i(16), dgn.to_i(16), src.to_i(16))
hex_id = bits.to_i(2).to_s(16)

# See RV-C Specification, Table 6.25.6a

# Stop the alternate instance
hex_data = sprintf('%02xFF%02x%02x%02x00FFFF',
                   options[:alternate].to_i,
                   stop_brightness,
                   stop_command,
                   stop_delay)
system "cansend can0 #{hex_id}##{hex_data}"

# Start the primary instance
hex_data = sprintf('%02xFF%02x%02x%02x00FFFF',
                   options[:instance].to_i,
                   start_brightness,
                   start_command,
                   options[:delay].to_i)
system "cansend can0 #{hex_id}##{hex_data}"

