#!/usr/bin/env ruby

require 'yaml'
require 'json'
require 'mqtt'

decoder_location = './tiffin-2018-phaeton-40ih.yaml'
mqtt_address = 'r2'

def publish_hass_status(subtopic, message_str, decoder, mqtt)
  topic_parts = subtopic.split('/')
  message = JSON.parse(message_str)

  case decoder['type']
  when 'light'
    hass_topic = 'homeassistant/light/rvc/' + topic_parts[1]
    state_message = {
      state: message['load_status'] == '00' ? 'OFF' : 'ON',
      brightness: message['operating_status_brightness'] / 100 * 255
    }
    mqtt.publish "#{hass_topic}/state", state_message.to_json
  end
end


def publish_hass_configs(topic, definition, mqtt)
  topic_parts = topic.split('/')

  case definition['type']
  when 'light'
    hass_topic = 'homeassistant/light/rvc/' + topic_parts[1]
    config_message = {
      '~': hass_topic,
      schema: 'json',
      name: definition['name'],
      brightness: definition['brightness'],
      brightness_scale: 255,
      command_topic: '~/set',
      state_topic: '~/state',
    }
    mqtt.publish "#{hass_topic}/config", config_message.to_json
  end
end


#################################################################
#
# Main program entry
#

mqtt = MQTT::Client.connect(mqtt_address)
decoder = YAML.load(File.read(decoder_location))

decoder['devices'].each do |topic, definition|
  publish_hass_configs(topic, definition, mqtt)
end

topics = decoder['devices'].keys
mqtt.get('rvc/+/+/json') do |topic, message|
  subtopic = topic[%r{rvc/(.+)/json}, 1]

  if (topics.include?(subtopic))
    publish_hass_status(subtopic, message, decoder['devices'][subtopic], mqtt)
  end

end
