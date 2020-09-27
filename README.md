# RV Control

This project's goal is to enable two-way communication between an RV's CAN bus
network and an MQTT message broker. It is not meant to be an end-to-end RV
control or automation solution, but rather a foundation which other tools and
projects can be built upon.

This is a from-scratch rewrite of some of the components of
[CoachProxyOS](https://github.com/rvc-proxy/coachproxy-os/).

Download the complete [RV-C
specification](http://www.rv-c.com/?q=node/75) for details on the
protocol and its messages. This PDF file is critical for
understanding how to communicate with RV-C devices.

What it does
------------

Monitoring:
* Receives raw RV-C messages from the CAN bus.
* Decodes those messages into human-readable JSON objects according to the RV-C specification.
* Decodes additional, vendor-proprietary RV-C messages (currently just a few custom messages used by Spyder Controls).
* Publishes decoded messages to an MQTT message broker.

Controlling:
* Receives commands from the MQTT Broker.
* Encodes those commands into RV-C messages.
* Sends the messages onto the CAN bus.

What it does NOT do
-------------------

* Interpretation of messages (e.g. this message means "Hallway Light").
* Any kind of logic (e.g. do something when a certain message is recevied).
* Any kind of user interface.

System overview
---------------

The yellow area outlines the scope of this project. Other example
components may be developed at a future date.

![System Overview Diagram](images/rv_control_diagram.png?raw=true)

Requirements
------------

* A computer with a CAN bus network card. This will almost certainly be a
Raspberry Pi 3B computer with a PiCAN2 board.
* The latest Raspberry Pi OS operating system image (Buster Lite is used for
development).
* The Ruby development environment and supporting Gems:
  ~~~
  sudo apt -y install ruby-dev
  sudo gem install json yaml mqtt
  ~~~
* An MQTT message broker to communicate with. Often this will run on the same
Raspberry Pi, and can be installed easily:
  ~~~
  sudo apt -y install mosquitto
  ~~~

# Software Documentation

More details coming soon.

RV-C Monitoring
---------------

The `rvc2mqtt.rb` script in the `rvc-to-mqtt/` directory listens on the canbus,
decodes all RV-C messages, and publishes the decoded result to an MQTT server.
The `rvc-spec.yaml` file provides the instructions for decoding the RV-C spec.

A great way to view the decoded messages is with the [MQTT
Explorer](http://mqtt-explorer.com/) application. Just connect to the MQTT
broker and monitor all the RV-C messages decoded from the CAN bus.

![MQTT Explorer Sample](images/mqtt_explorer.png?raw=true)

The intent is to publish the raw RV-C data in an easily consumable format so
that other tools can then interpret and if needed republish the data in other
formats. For example, a program might subscribe to MQTT messages on topic
`DC_DIMMER_STATUS_3/1` and publish (under a different top-level MQTT topic) a
message such as `Main_Ceiling_Light`.

The fully decoded message is published as a JSON object under the `json`
parameter, and each individual component is published as strings or numbers.
Individual parameters makes it easier for programs to monitor a specific
paramenter, such as `operating_status_brightness` for a light. However, if multiple
parameters are needed, they must be extracted from the combined `json` parameter to ensure
they are all from the same RV-C message. For example, calculating a holding tank level
requires dividing the `relative_level` by the `resolution`.

RV-C Controlling
----------------

Programs in the `rvc-commands` directory are used to send commands to the RV-C
canbus. Currently these are command-line executable scripts, but the long-term
goal is to send RV-C commands based on incoming MQTT command messages.

`dc_dimmer_command_2.rb` - Sends a DC_DIMMER_COMMAND_2 (1FEDB) message to the
canbus. Although the RV-C specification indicates this command is intended for
dimmable lights, Spyder Controls uses it to control many other DC loads,
including the water pump, ceiling fans, and more.

`dc_dimmer_command_2_pair.rb` - For bidirectional DC devices such as vent lids,
TV lifts, and window shades, Spyder Controls often uses a pair of DC Dimmer
IDs, each controlling motion in one direction. An `OFF` message is sent to the
_undesired_ direction, to stop any existing motion, and a `Toggle` message is
sent to the desired direction to initiate movement for a defined duration. If
the same command is sent again, the second `Toggle` will stop the current
motion without reversing the direction of the device, to stop a shade partway
for example.

`thermostat_command.rb`

`window_shade_command.rb`

`ac_load_command.rb`
