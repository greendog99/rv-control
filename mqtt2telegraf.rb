#!/usr/bin/ruby

require 'mqtt'
require 'json'

mqtt_address = '192.168.50.114'
publish_topic = 'telegraf/rvc'

thermostat_ambient_status_instances = { 0 => 'front_floor', 1 => 'rear_floor', 2 => 'front_ceiling', 3 => 'mid_ceiling', 4 => 'rear_ceiling', 6 => 'wet_bay', 7 => 'generator_bay' }

# Make a string more computer-friendly.
def sanitize_string(str)
  str ? str.downcase.tr(' /', '_').tr('()', '') : nil
end


MQTT::Client.connect(mqtt_address) do |c|
  # Subscribe to all rvc messages
  c.get('rvc/+/+/json') do |topic, message|
    json = JSON.parse(message)

    case topic
    when /THERMOSTAT_AMBIENT_STATUS/
      location = thermostat_ambient_status_instances[json['instance']]
      temp_f = json['ambient_temp_f']
      c.publish publish_topic, "rvc_thermostat_ambient_status,location=#{location} temp_f=#{temp_f}"
    when /ATS_AC_STATUS_1/
      leg = json['leg_definition']
      amps = json['rms_current']
      volts = json['rms_voltage']
      watts = amps * volts
      frequency = json['frequency']
      c.publish publish_topic, "rvc_ats_ac_status_1,leg=#{leg} current=#{amps},voltage=#{volts},power=#{watts},frequency=#{frequency}"
    when /TANK_STATUS/
      name = sanitize_string json['instance_definition']
      level = 100.0 * json['relative_level'] / json['resolution']
      c.publish publish_topic, "rvc_tank_status,tank=#{name} level=#{level}"
    end
  end
end

