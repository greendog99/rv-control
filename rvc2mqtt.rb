#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'mqtt'
require 'open3'
require './rvc_parser'
require './bitmath'

rvc_spec_location = './rvc-spec.yml'
mqtt_address = 'r2'

# Parse the text output of candump and decode various information as
# described in RV-C Revised Application Layer section 3.2.
#
# Sample input:
# (1550629697.810979)  can0  19FFD442   [8]  01 02 F7 FF FF FF FF FF
#
def parse_candump_line(line)
  columns = line.split(/\s+/)
  time = columns[0].gsub(/[^0-9]/, '')  # timestamp in microseconds
  prio = columns[2].hex.bitrange(26..28, bytes: 8)
  dgn  = columns[2].hex.bitrange(8..24, bytes: 8)
  src  = columns[2].hex.bitrange(0..7, bytes: 8)
  dgn = dgn.to_s(16).upcase.rjust(5, '0')  # Change back to hex, e.g "0E1F7"
  len  = columns[3].gsub(/[^0-9]/, '').to_i  # number of data bytes
  data = columns[4..(4+len)].join()

  { time: time, prio: prio, dgn: dgn, src: src, len: len, data: data }
end


#################################################################
#
# Main program entry
#

rvc_spec = RVCParser.new
mqtt = MQTT::Client.connect(host: mqtt_address)

# Publish rvc_spec version number
api_version = rvc_spec.api_version
mqtt.publish('rvc/api_version', api_version, true)

# Monitor the canbus, decode each line, and publish the results to mqtt.
Open3.popen3('/usr/bin/candump -ta can0') do |stdin, stdout, stderr, wait_thr|
  while line = stdout.gets.strip do
    message = parse_candump_line(line)
    decoded = rvc_spec.decode(message[:dgn], message[:data])
    decoded['timestamp'] = message[:time]

    topic = 'rvc/' + decoded['name']
    topic += '/' + decoded['instance'].to_s if decoded['instance']
    mqtt.publish(topic + '/json', decoded.sort.to_h.to_json, false)
    decoded.each do | key, value |
      mqtt.publish(topic + '/' + key, value, false)
    end
  end
end
