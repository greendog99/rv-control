# RV Control

A re-write from scratch of
[CoachProxyOS](https://github.com/rvc-proxy/coachproxy-os/)
scripts to monitor and send RV-C messages.

Raspberry Pi 3B Setup
---------------------

Install latest Raspbian Buster lite image.

~~~
sudo apt -y install ruby-dev
sudo gem install json yaml mqtt
~~~

RV-C Decoding
-------------

The `rvc2mqtt.rb` script in the `rvc-to-mqtt/` directory listens on the canbus,
decodes all RV-C messages, and publishes the decoded result to an MQTT
server. The `rvc-spec.yaml` file provides the instructions for decoding
the RV-C spec.

RV-C Control
------------

Programs in the `rvc-commands` directory are used to send commands to the RVC
canbus.

Programs:

`dc_dimmer_command_2.rb` - Sends a DC_DIMMER_COMMAND_2 (1FEDB) message to the
canbus. Although the RV-C specification indicates this command is intended for
dimmable lights, Spyder Controls uses it to control many other DC loads,
including the water pump, ceiling fans, electric water heater, and more.

`dc_dimmer_command_2_pair.rb` - For bidirectional DC devices such as vent lids,
TV lifts, and window shades, Spyder Controls often uses a pair of DC Dimmer
IDs, each controlling motion in one direction. An `OFF` message is sent to the
undesired direction, to stop any existing motion, and an `Toggle` message is
sent to the desired direction to initiate movement for a defined duration. If
the same command is sent again, the second `Toggle` will stop the current
motion without reversing the direction of the device, to stop a shade partway
for example.


