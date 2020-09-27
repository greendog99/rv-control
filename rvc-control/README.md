RV-C Control
============

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

