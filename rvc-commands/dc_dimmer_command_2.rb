#!/usr/bin/env ruby
#
# Send DC_DIMMER_COMMAND_2

require 'optparse'

options = {}
OptionParser.new do |opts|
  options[:brightness] = 100
  options[:delay] = 255

  opts.on('-i', '--instance NUM', Integer, '[REQUIRED] Dimmer instance to control')
  opts.on('-c', '--command HEX', String, '[REQUIRED] Hex command code to send (e.g.: 13')
  opts.on('-b', '--brightness NUM', Integer, 'Desired level (brightness), 0-100, 250, 251')
  opts.on('-d', '--delay NUM', '--duration NUM', Integer, 'Seconds before executing, or duration of command')
  opts.on('-h', '--help', 'Display this screen' ) do
    puts opts
    puts "\nCommon commands:\n"
    exit
  end
end.parse!(into: options)

if (options[:instance].nil? || options[:command].nil?)
  raise OptionParser::MissingArgument.new("instance and command are required arguments")
end

dgn = '1FEDB'
pri = '0x6'
src = '0x99'

# See RV-C Specification, section 3.2
# dgn_hi = dgn.slice(0..2)
# dgn_lo = dgn.slice(3..4)
# bits = sprintf('%b0%b%b%b', pri.to_i(16), dgn_hi.to_i(16), dgn_lo.to_i(16), src.to_i(16))
bits = sprintf('%b0%b%b', pri.to_i(16), dgn.to_i(16), src.to_i(16))
hex_id = bits.to_i(2).to_s(16)

# See RV-C Specification, Table 6.25.6a
hex_data = sprintf('%02xFF%02x%02x%02x00FFFF',
                   options[:instance].to_i,
                   options[:brightness].to_i * 2,
                   options[:command].to_i(16),
                   options[:delay].to_i)

system "cansend can0 #{hex_id}##{hex_data}"

